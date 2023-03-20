//
//  DiccionarioAppTests.swift
//  DiccionarioAppTests
//
//  Created by Alvar Arias on 2023-03-18.
//

import XCTest
import Combine
@testable import DiccionarioApp

final class DiccionarioAppTests: XCTestCase {
        
    var viewModel: WordViewModel!
    var cancellables: Set<AnyCancellable> = []

    override func setUp() {
        super.setUp()
        viewModel = WordViewModel()
    }

    override func tearDown() {
        cancellables.removeAll()
        super.tearDown()
    }

    func testFetchPosts() {
        let expectation = XCTestExpectation(description: "Fetching posts from API")
        let word = "katt"
        let dir = "to"
        let url = URL(string: "http://lexin.nada.kth.se/lexin/service?searchinfo=\(dir),swe_spa,\(word)&output=JSON")!

        viewModel.$results
            .dropFirst()
            .sink(receiveValue: { results in
                // Assert that at least one result was returned
                XCTAssertGreaterThan(results.count, 0)
                expectation.fulfill()
            })
            .store(in: &cancellables)

        viewModel.fetchPosts(word: word, dir: dir)

        wait(for: [expectation], timeout: 5.0)
    }

     
}


/*
override func setUpWithError() throws {
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

override func tearDownWithError() throws {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}

func testExample() throws {
    // This is an example of a functional test case.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
    // Any test you write for XCTest can be annotated as throws and async.
    // Mark your test throws to produce an unexpected failure when your test encounters an uncaught error.
    // Mark your test async to allow awaiting for asynchronous code to complete. Check the results with assertions afterwards.
}

func testPerformanceExample() throws {
    // This is an example of a performance test case.
    measure {
        // Put the code you want to measure the time of here.
    }
}
*/
