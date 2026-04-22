//
//  DiccionarioAppUITests.swift
//  DiccionarioAppUITests
//
//  Created by Alvar Arias on 2023-03-17.
//

import XCTest

final class DiccionarioAppUITests: XCTestCase {

    var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
    }

    override func tearDownWithError() throws {
        app = nil
    }

    // MARK: - Search bar

    func testSearchBarIsVisible() throws {
        let searchField = app.textFields["Search"]
        XCTAssertTrue(searchField.waitForExistence(timeout: 3))
    }

    func testSearchButtonIsVisible() throws {
        let searchButton = app.buttons["Button Search"]
        XCTAssertTrue(searchButton.waitForExistence(timeout: 3))
    }

    func testCanTypeInSearchBar() throws {
        let searchField = app.textFields["Search"]
        XCTAssertTrue(searchField.waitForExistence(timeout: 3))

        searchField.tap()
        searchField.typeText("katt")

        XCTAssertEqual(searchField.value as? String, "katt")
    }

    func testSearchButtonTapDoesNotCrash() throws {
        let searchField = app.textFields["Search"]
        let searchButton = app.buttons["Button Search"]
        XCTAssertTrue(searchField.waitForExistence(timeout: 3))

        searchField.tap()
        searchField.typeText("katt")
        searchButton.tap()

        XCTAssertTrue(app.exists)
    }

    // MARK: - Language toggle

    func testLanguageToggleExists() throws {
        let toggle = app.switches.firstMatch
        XCTAssertTrue(toggle.waitForExistence(timeout: 3))
    }

    // MARK: - Toolbar buttons

    func testSettingsButtonExists() throws {
        let settingsButton = app.buttons.matching(identifier: "gear").firstMatch
        XCTAssertTrue(settingsButton.waitForExistence(timeout: 3))
    }

    // MARK: - Performance

    func testLaunchPerformance() {
        measure(metrics: [XCTApplicationLaunchMetric()]) {
            XCUIApplication().launch()
        }
    }
}
