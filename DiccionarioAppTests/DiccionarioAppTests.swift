//
//  DiccionarioAppTests.swift
//  DiccionarioAppTests
//
//  Created by Alvar Arias on 2023-03-18.
//

import XCTest
import Combine
@testable import DiccionarioApp

@MainActor
final class DiccionarioAppTests: XCTestCase {

    var cancellables: Set<AnyCancellable> = []

    override func tearDown() {
        cancellables.removeAll()
        UserDefaults.standard.removeObject(forKey: "FavoriteWords")
        super.tearDown()
    }

    // MARK: - WordViewModel

    func testFetchPostsReturnsResults() async throws {
        let viewModel = WordViewModel()
        let expectation = XCTestExpectation(description: "API returns results for 'katt'")

        viewModel.$results
            .dropFirst()
            .sink { results in
                XCTAssertGreaterThan(results.count, 0)
                expectation.fulfill()
            }
            .store(in: &cancellables)

        viewModel.fetchPosts(word: "katt", dir: "to")

        await fulfillment(of: [expectation], timeout: 10.0)
    }

    func testFetchPostsPublishesErrorForUnknownWord() async throws {
        let viewModel = WordViewModel()
        let expectation = XCTestExpectation(description: "Error publisher fires for unknown word")

        viewModel.errorPublisher
            .sink { message in
                XCTAssertFalse(message.isEmpty)
                expectation.fulfill()
            }
            .store(in: &cancellables)

        viewModel.fetchPosts(word: "zzzznotaword99999", dir: "to")

        await fulfillment(of: [expectation], timeout: 10.0)
    }

    func testFetchPostsFromDirection() async throws {
        let viewModel = WordViewModel()
        let expectation = XCTestExpectation(description: "API returns results for 'gato' in 'from' direction")

        viewModel.$results
            .dropFirst()
            .sink { results in
                XCTAssertGreaterThan(results.count, 0)
                expectation.fulfill()
            }
            .store(in: &cancellables)

        viewModel.fetchPosts(word: "gato", dir: "from")

        await fulfillment(of: [expectation], timeout: 10.0)
    }

    // MARK: - Model Decoding

    func testResultDecodingFromJSON() throws {
        let json = """
        {
            "Status": "OK",
            "Wordbase": "swe_spa",
            "Result": [
                {
                    "Value": "katt",
                    "Type": "subst.",
                    "VariantID": "1",
                    "BaseLang": {
                        "Phonetic": { "File": "katt.mp3", "Content": "kat" },
                        "Inflection": [{ "Content": "katten" }],
                        "Meaning": "husdjuret Felis ocreata domestica",
                        "Illustration": [],
                        "Comment": null
                    },
                    "TargetLang": {
                        "Translation": "gato",
                        "Synonym": ["michi"],
                        "Comment": null
                    }
                }
            ]
        }
        """.data(using: .utf8)!

        let words = try JSONDecoder().decode(Words.self, from: json)

        XCTAssertEqual(words.status, "OK")
        XCTAssertEqual(words.result.count, 1)
        let result = words.result[0]
        XCTAssertEqual(result.value, "katt")
        XCTAssertEqual(result.type, "subst.")
        XCTAssertEqual(result.baseLang?.meaning, "husdjuret Felis ocreata domestica")
        XCTAssertEqual(result.baseLang?.phonetic?.content, "kat")
        XCTAssertEqual(result.baseLang?.phonetic?.file, "katt.mp3")
        XCTAssertEqual(result.baseLang?.inflection?.first?.content, "katten")
        XCTAssertEqual(result.targetLang?.translation, "gato")
        XCTAssertEqual(result.targetLang?.synonym?.first, "michi")
    }

    func testResultDecodingWithMissingOptionalFields() throws {
        let json = """
        {
            "Status": "OK",
            "Wordbase": "swe_spa",
            "Result": [
                {
                    "Value": "hund",
                    "Type": "subst.",
                    "VariantID": null,
                    "BaseLang": null,
                    "TargetLang": null
                }
            ]
        }
        """.data(using: .utf8)!

        let words = try JSONDecoder().decode(Words.self, from: json)
        let result = words.result[0]

        XCTAssertEqual(result.value, "hund")
        XCTAssertNil(result.baseLang)
        XCTAssertNil(result.targetLang)
        XCTAssertNil(result.variantID)
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

        let stored = UserDefaults.standard.stringArray(forKey: "FavoriteWords")
        XCTAssertEqual(stored, ["katt"])
    }

    func testWordListLoadsFromUserDefaults() {
        UserDefaults.standard.set(["hund", "katt"], forKey: "FavoriteWords")

        let vm = WordListViewModel()

        XCTAssertEqual(vm.favoriteWords, ["hund", "katt"])
    }

    // MARK: - AppEnvironment

    func testDefaultLanguageIsEnglish() {
        let env = AppEnvironment()
        XCTAssertEqual(env.currentLanguage, "en")
    }

    func testLanguageChangeUpdatesPublishedValue() {
        let env = AppEnvironment()
        env.currentLanguage = "sv"
        XCTAssertEqual(env.currentLanguage, "sv")
    }

    // MARK: - UserViewModel

    func testUserViewModelInactiveByDefault() {
        let vm = UserViewModel(isSubscriptionActive: false)
        XCTAssertFalse(vm.isSubscriptionActive)
    }

    func testUserViewModelActiveState() {
        let vm = UserViewModel(isSubscriptionActive: true)
        XCTAssertTrue(vm.isSubscriptionActive)
    }
}
