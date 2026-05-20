//
//  DiccionarioAppTests.swift
//  DiccionarioAppTests
//
//  Created by Alvar Arias on 2023-03-18.
//

import XCTest
import Combine
import CoreData
@testable import DiccionarioApp

// MARK: - MockURLProtocol

final class MockURLProtocol: URLProtocol {
    nonisolated(unsafe) static var requestHandler: ((URLRequest) throws -> (HTTPURLResponse, Data))?

    override class func canInit(with request: URLRequest) -> Bool { true }
    override class func canonicalRequest(for request: URLRequest) -> URLRequest { request }

    override func startLoading() {
        guard let handler = MockURLProtocol.requestHandler else {
            client?.urlProtocol(self, didFailWithError: URLError(.unknown))
            return
        }
        do {
            let (response, data) = try handler(request)
            client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            client?.urlProtocol(self, didLoad: data)
            client?.urlProtocolDidFinishLoading(self)
        } catch {
            client?.urlProtocol(self, didFailWithError: error)
        }
    }

    override func stopLoading() {}
}

extension URLSession {
    static var mock: URLSession {
        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [MockURLProtocol.self]
        return URLSession(configuration: config)
    }
}

// MARK: - CoreData helpers

private func makeInMemoryContext() -> NSManagedObjectContext {
    let container = NSPersistentContainer(name: "WordModel")
    let description = NSPersistentStoreDescription()
    description.type = NSInMemoryStoreType
    container.persistentStoreDescriptions = [description]
    container.loadPersistentStores { _, error in
        if let error = error { fatalError("Test CoreData store failed: \(error)") }
    }
    return container.viewContext
}

private func makeWords(count: Int, in context: NSManagedObjectContext) -> [myWord] {
    (0..<count).map { i in
        let word = myWord(context: context)
        word.value = "word\(i)"
        word.translation = "translation\(i)"
        word.type = "noun"
        return word
    }
}

// MARK: - JSON helpers

private func lexinJSON(word: String = "katt", translation: String = "gato") -> Data {
    Data("""
    {
        "Status": "OK", "Wordbase": "swe_spa",
        "Result": [{
            "Value": "\(word)", "Type": "subst.", "VariantID": "1",
            "BaseLang": { "Phonetic": { "File": "\(word).mp3", "Content": "IPA" },
                          "Inflection": [{ "Content": "\(word)en" }],
                          "Meaning": "test meaning", "Illustration": [], "Comment": null },
            "TargetLang": { "Translation": "\(translation)", "Synonym": null, "Comment": null }
        }]
    }
    """.utf8)
}

private func lexinResponse(statusCode: Int = 200, for request: URLRequest) -> HTTPURLResponse {
    HTTPURLResponse(url: request.url!, statusCode: statusCode, httpVersion: nil, headerFields: nil)!
}

// MARK: - Tests

@MainActor
final class DiccionarioAppTests: XCTestCase {

    var cancellables: Set<AnyCancellable> = []

    override func tearDown() {
        cancellables.removeAll()
        UserDefaults.standard.removeObject(forKey: "FavoriteWords")
        MockURLProtocol.requestHandler = nil
        super.tearDown()
    }

    // MARK: - WordViewModel — API connection errors

    func testFetchPosts_networkError_publishesNoWordMatch() async {
        let vm = WordViewModel(session: .mock)
        let expectation = expectation(description: "network error")

        MockURLProtocol.requestHandler = { _ in throw URLError(.notConnectedToInternet) }

        vm.errorPublisher
            .sink { msg in XCTAssertEqual(msg, "No word match"); expectation.fulfill() }
            .store(in: &cancellables)

        vm.fetchPosts(word: "katt", dir: "swe")
        await fulfillment(of: [expectation], timeout: 5)
    }

    func testFetchPosts_http500_publishesInvalidResponse() async {
        let vm = WordViewModel(session: .mock)
        let expectation = expectation(description: "http 500")

        MockURLProtocol.requestHandler = { req in (lexinResponse(statusCode: 500, for: req), Data()) }

        vm.errorPublisher
            .sink { msg in XCTAssertEqual(msg, "Invalid response"); expectation.fulfill() }
            .store(in: &cancellables)

        vm.fetchPosts(word: "katt", dir: "swe")
        await fulfillment(of: [expectation], timeout: 5)
    }

    func testFetchPosts_http404_publishesInvalidResponse() async {
        let vm = WordViewModel(session: .mock)
        let expectation = expectation(description: "http 404")

        MockURLProtocol.requestHandler = { req in (lexinResponse(statusCode: 404, for: req), Data()) }

        vm.errorPublisher
            .sink { msg in XCTAssertEqual(msg, "Invalid response"); expectation.fulfill() }
            .store(in: &cancellables)

        vm.fetchPosts(word: "katt", dir: "swe")
        await fulfillment(of: [expectation], timeout: 5)
    }

    func testFetchPosts_malformedJSON_publishesNoWordMatch() async {
        let vm = WordViewModel(session: .mock)
        let expectation = expectation(description: "bad json")

        MockURLProtocol.requestHandler = { req in (lexinResponse(for: req), Data("not json".utf8)) }

        vm.errorPublisher
            .sink { msg in XCTAssertEqual(msg, "No word match"); expectation.fulfill() }
            .store(in: &cancellables)

        vm.fetchPosts(word: "katt", dir: "swe")
        await fulfillment(of: [expectation], timeout: 5)
    }

    func testFetchPosts_correctionsOnly_publishesNoWordMatch() async {
        let vm = WordViewModel(session: .mock)
        let expectation = expectation(description: "corrections only")

        let json = Data(#"{"Status":"OK","Wordbase":"swe_spa","Corrections":["katten","katta"]}"#.utf8)
        MockURLProtocol.requestHandler = { req in (lexinResponse(for: req), json) }

        vm.errorPublisher
            .sink { msg in XCTAssertEqual(msg, "No word match"); expectation.fulfill() }
            .store(in: &cancellables)

        vm.fetchPosts(word: "kattt", dir: "swe")
        await fulfillment(of: [expectation], timeout: 5)
    }

    func testFetchPosts_emptyResultArray_publishesNoWordMatch() async {
        let vm = WordViewModel(session: .mock)
        let expectation = expectation(description: "empty results")

        let json = Data(#"{"Status":"OK","Wordbase":"swe_spa","Result":[]}"#.utf8)
        MockURLProtocol.requestHandler = { req in (lexinResponse(for: req), json) }

        vm.errorPublisher
            .sink { msg in XCTAssertEqual(msg, "No word match"); expectation.fulfill() }
            .store(in: &cancellables)

        vm.fetchPosts(word: "xyznotaword", dir: "swe")
        await fulfillment(of: [expectation], timeout: 5)
    }

    func testFetchPosts_validResponse_publishesOKAndPopulatesResults() async {
        let vm = WordViewModel(session: .mock)
        let errorExp = expectation(description: "OK published")
        let resultsExp = expectation(description: "results populated")

        MockURLProtocol.requestHandler = { req in (lexinResponse(for: req), lexinJSON()) }

        vm.errorPublisher
            .sink { msg in XCTAssertEqual(msg, "OK"); errorExp.fulfill() }
            .store(in: &cancellables)

        vm.$results.dropFirst()
            .sink { results in
                XCTAssertEqual(results.count, 1)
                XCTAssertEqual(results.first?.value, "katt")
                resultsExp.fulfill()
            }
            .store(in: &cancellables)

        vm.fetchPosts(word: "katt", dir: "swe")
        await fulfillment(of: [errorExp, resultsExp], timeout: 5)
    }

    func testFetchPosts_usesSweDirNotTo() async {
        let vm = WordViewModel(session: .mock)
        let expectation = expectation(description: "dir check")
        var capturedURL: URL?

        MockURLProtocol.requestHandler = { req in
            capturedURL = req.url
            return (lexinResponse(for: req), lexinJSON())
        }

        vm.errorPublisher.sink { _ in expectation.fulfill() }.store(in: &cancellables)
        vm.fetchPosts(word: "katt", dir: "swe")
        await fulfillment(of: [expectation], timeout: 5)

        XCTAssertTrue(capturedURL?.absoluteString.contains("searchinfo=swe") == true,
                      "Must use 'swe', not 'to'")
        XCTAssertFalse(capturedURL?.absoluteString.contains("searchinfo=to") == true)
    }

    func testFetchPosts_usesSpaDir() async {
        let vm = WordViewModel(session: .mock)
        let expectation = expectation(description: "spa dir check")
        var capturedURL: URL?

        MockURLProtocol.requestHandler = { req in
            capturedURL = req.url
            return (lexinResponse(for: req), lexinJSON(word: "gato", translation: "katt"))
        }

        vm.errorPublisher.sink { _ in expectation.fulfill() }.store(in: &cancellables)
        vm.fetchPosts(word: "gato", dir: "spa")
        await fulfillment(of: [expectation], timeout: 5)

        XCTAssertTrue(capturedURL?.absoluteString.contains("searchinfo=spa") == true,
                      "Must use 'spa', not 'from'")
        XCTAssertFalse(capturedURL?.absoluteString.contains("searchinfo=from") == true)
    }

    // MARK: - WordViewModel — Lexin quote bug fix

    func testLexinQuoteBugFix_fixesEscapedBackslashBeforeQuote() {
        // The Lexin API encodes \" as \" (backslash + literal quote),
        // which terminates the JSON string prematurely. The fix converts it to \".
        let buggy    = "before \\u005c\" after"  // raw: before \" after
        let expected = "before \\\" after"       // raw: before \" after
        let result   = buggy.replacingOccurrences(of: "\\u005c\"", with: "\\\"")
        XCTAssertEqual(result, expected)
    }

    // MARK: - Model Decoding

    func testResultDecodingFromJSON() throws {
        let json = """
        {
            "Status": "OK", "Wordbase": "swe_spa",
            "Result": [{
                "Value": "katt", "Type": "subst.", "VariantID": "1",
                "BaseLang": {
                    "Phonetic": { "File": "katt.mp3", "Content": "kat" },
                    "Inflection": [{ "Content": "katten" }],
                    "Meaning": "husdjuret Felis ocreata domestica",
                    "Illustration": [], "Comment": null
                },
                "TargetLang": { "Translation": "gato", "Synonym": ["michi"], "Comment": null }
            }]
        }
        """.data(using: .utf8)!

        let words = try JSONDecoder().decode(Words.self, from: json)
        let results = try XCTUnwrap(words.result)

        XCTAssertEqual(words.status, "OK")
        XCTAssertEqual(results.count, 1)
        let r = results[0]
        XCTAssertEqual(r.value, "katt")
        XCTAssertEqual(r.type, "subst.")
        XCTAssertEqual(r.baseLang?.meaning, "husdjuret Felis ocreata domestica")
        XCTAssertEqual(r.baseLang?.phonetic?.content, "kat")
        XCTAssertEqual(r.baseLang?.phonetic?.file, "katt.mp3")
        XCTAssertEqual(r.baseLang?.inflection?.first?.content, "katten")
        XCTAssertEqual(r.targetLang?.translation, "gato")
        XCTAssertEqual(r.targetLang?.synonym?.first, "michi")
    }

    func testResultDecodingWithMissingOptionalFields() throws {
        let json = """
        {
            "Status": "OK", "Wordbase": "swe_spa",
            "Result": [{ "Value": "hund", "Type": "subst.", "VariantID": null,
                         "BaseLang": null, "TargetLang": null }]
        }
        """.data(using: .utf8)!

        let results = try XCTUnwrap(JSONDecoder().decode(Words.self, from: json).result)
        XCTAssertEqual(results[0].value, "hund")
        XCTAssertNil(results[0].baseLang)
        XCTAssertNil(results[0].targetLang)
        XCTAssertNil(results[0].variantID)
    }

    func testCorrectionsDecodingWhenNoResultMatch() throws {
        let json = """
        { "Status": "OK", "Wordbase": "swe_spa",
          "Corrections": ["katten", "katta", "katter"] }
        """.data(using: .utf8)!

        let words = try JSONDecoder().decode(Words.self, from: json)
        XCTAssertNil(words.result)
        XCTAssertEqual(words.corrections?.count, 3)
        XCTAssertEqual(words.corrections?.first, "katten")
    }

    // MARK: - WordSearchViewModel

    func testPerformSearch_emptyString_doesNothing() {
        let vm = WordSearchViewModel()
        vm.performSearch(text: "")
        XCTAssertFalse(vm.showProgressBar)
        XCTAssertTrue(vm.searchWords.isEmpty)
    }

    func testPerformSearch_setsShowProgressBar() {
        let vm = WordSearchViewModel()
        vm.performSearch(text: "katt")
        XCTAssertTrue(vm.showProgressBar)
    }

    func testPerformSearch_addsWordToHistory() {
        let vm = WordSearchViewModel()
        vm.performSearch(text: "katt")
        XCTAssertTrue(vm.searchWords.contains("katt"))
    }

    func testPerformSearch_doesNotDuplicateHistory() {
        let vm = WordSearchViewModel()
        vm.performSearch(text: "katt")
        vm.performSearch(text: "katt")
        XCTAssertEqual(vm.searchWords.filter { $0 == "katt" }.count, 1)
    }

    func testPerformSearch_lowercasesInput() {
        let vm = WordSearchViewModel()
        vm.performSearch(text: "KATT")
        XCTAssertTrue(vm.searchWords.contains("katt"))
        XCTAssertFalse(vm.searchWords.contains("KATT"))
    }

    func testSuggestions_emptyText_returnsEmpty() {
        XCTAssertTrue(WordSearchViewModel().suggestions(for: "").isEmpty)
    }

    func testSuggestions_matchingHistory_returnsResult() {
        let vm = WordSearchViewModel()
        vm.performSearch(text: "katt")
        XCTAssertTrue(vm.suggestions(for: "ka").contains("katt"))
    }

    func testSuggestions_nonMatchingHistory_excludesResult() {
        let vm = WordSearchViewModel()
        vm.performSearch(text: "hund")
        XCTAssertFalse(vm.suggestions(for: "ka").contains("hund"))
    }

    func testVoiceLocale_selectedLangTrue_returnsSvSE() {
        let vm = WordSearchViewModel()
        vm.selectedLang = true
        XCTAssertEqual(vm.voiceLocale().identifier, "sv-SE")
    }

    func testVoiceLocale_selectedLangFalse_returnsEsMX() {
        let vm = WordSearchViewModel()
        vm.selectedLang = false
        XCTAssertEqual(vm.voiceLocale().identifier, "es-MX")
    }

    // MARK: - WordListViewModel

    func testAddWordAppendsToList() {
        let vm = WordListViewModel()
        vm.favoriteWords = []
        vm.addWord("katt")
        vm.addWord("hund")
        XCTAssertEqual(vm.favoriteWords, ["katt", "hund"])
    }

    func testRemoveWordDeletesAtOffset() {
        let vm = WordListViewModel()
        vm.favoriteWords = ["katt", "hund", "fisk"]
        vm.removeWord(at: IndexSet(integer: 1))
        XCTAssertEqual(vm.favoriteWords, ["katt", "fisk"])
    }

    func testWordListPersistsToUserDefaults() {
        let vm = WordListViewModel()
        vm.favoriteWords = []
        vm.addWord("katt")
        XCTAssertEqual(UserDefaults.standard.stringArray(forKey: "FavoriteWords"), ["katt"])
    }

    func testWordListLoadsFromUserDefaults() {
        UserDefaults.standard.set(["hund", "katt"], forKey: "FavoriteWords")
        XCTAssertEqual(WordListViewModel().favoriteWords, ["hund", "katt"])
    }

    // MARK: - AppEnvironment

    func testDefaultLanguageIsEnglish() {
        XCTAssertEqual(AppEnvironment().currentLanguage, "en")
    }

    func testLanguageChangeUpdatesPublishedValue() {
        let env = AppEnvironment()
        env.currentLanguage = "sv"
        XCTAssertEqual(env.currentLanguage, "sv")
    }

    // MARK: - UserViewModel

    func testUserViewModelInactiveByDefault() {
        XCTAssertFalse(UserViewModel(isSubscriptionActive: false).isSubscriptionActive)
    }

    func testUserViewModelActiveState() {
        XCTAssertTrue(UserViewModel(isSubscriptionActive: true).isSubscriptionActive)
    }

    // MARK: - TriviaViewModel

    func testTriviaStartGame_initializesState() {
        let context = makeInMemoryContext()
        let vm = TriviaViewModel()
        vm.startGame(words: makeWords(count: 5, in: context))

        XCTAssertEqual(vm.currentQuestion, 1)
        XCTAssertEqual(vm.score, 0)
        XCTAssertFalse(vm.gameEnded)
        XCTAssertEqual(vm.questionsPerGame, 5)
    }

    func testTriviaUpdateRandomIndex_indicesWithinBounds() {
        let context = makeInMemoryContext()
        let words = makeWords(count: 10, in: context)
        let vm = TriviaViewModel()
        for _ in 0..<20 {
            vm.updateRandomIndex(words: words)
            XCTAssertTrue((0..<10).contains(vm.randomIndexP1))
            XCTAssertTrue((0..<10).contains(vm.randomIndexP2))
        }
    }

    func testTriviaUpdateRandomIndex_indicesAreDifferent() {
        let context = makeInMemoryContext()
        let words = makeWords(count: 10, in: context)
        let vm = TriviaViewModel()
        for _ in 0..<20 {
            vm.updateRandomIndex(words: words)
            XCTAssertNotEqual(vm.randomIndexP1, vm.randomIndexP2)
        }
    }

    func testTriviaUpdateRandomIndex_emptyWords_doesNotCrash() {
        let vm = TriviaViewModel()
        vm.updateRandomIndex(words: [])
        XCTAssertEqual(vm.randomIndexP1, 0)
    }

    func testTriviaCheckAnswer_incrementsScoreAndQuestion() {
        let context = makeInMemoryContext()
        let words = makeWords(count: 5, in: context)
        let vm = TriviaViewModel()
        vm.startGame(words: words)
        vm.checkAnswer(words: words)

        XCTAssertEqual(vm.score, 1)
        XCTAssertEqual(vm.currentQuestion, 2)
        XCTAssertFalse(vm.gameEnded)
    }

    func testTriviaCheckAnswer_lastQuestion_endsGame() {
        let context = makeInMemoryContext()
        let words = makeWords(count: 2, in: context)
        let vm = TriviaViewModel()
        vm.startGame(words: words)      // questionsPerGame=2, currentQuestion=1

        vm.checkAnswer(words: words)    // currentQuestion=2, 2>2 false
        XCTAssertFalse(vm.gameEnded)

        vm.checkAnswer(words: words)    // currentQuestion=3, 3>2 true
        XCTAssertTrue(vm.gameEnded)
    }

    // MARK: - QuizViewModel

    func testQuizUpdateRandomIndex_returnsValidIndex() {
        let context = makeInMemoryContext()
        let words = makeWords(count: 10, in: context)
        let vm = QuizViewModel()
        for _ in 0..<20 {
            vm.updateRandomIndex(words: words)
            XCTAssertTrue((0..<10).contains(vm.randomIndex))
        }
    }

    func testQuizUpdateRandomIndex_emptyWords_doesNotCrash() {
        let vm = QuizViewModel()
        vm.updateRandomIndex(words: [])
        XCTAssertEqual(vm.randomIndex, 0)
    }

    // MARK: - DetailViewModel

    func testDetailViewModel_saveNewWord_setsIsSaved() throws {
        let vm = DetailViewModel()
        let context = makeInMemoryContext()
        let result = Result(variantID: nil, value: "uniqueword_xyz", type: "noun",
                            baseLang: nil, targetLang: nil)

        vm.saveWord(result: result, selectedLang: true, context: context)

        XCTAssertTrue(vm.isSaved)
    }

    func testDetailViewModel_saveDuplicateWord_setsIsDuplicate() throws {
        let vm = DetailViewModel()
        let context = makeInMemoryContext()

        let existing = myWord(context: context)
        existing.value = "katt"
        try context.save()

        let result = Result(variantID: nil, value: "katt", type: "noun",
                            baseLang: nil, targetLang: nil)
        vm.saveWord(result: result, selectedLang: true, context: context)

        XCTAssertTrue(vm.isDuplicate)
    }
}
