//
//  DiccionarioAppUITests.swift
//  DiccionarioAppUITests
//
//  Created by Alvar Arias on 2023-03-17.
//

import XCTest

final class DiccionarioAppUITests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() throws {
        // UI tests must launch the application that they test.
        let app = XCUIApplication()
        app.launch()
        
        // Test 1 parte
        let textField = app.textFields["Search"]
        let button = app.buttons["Button Search"]
    
                textField.tap()
                textField.typeText("katt")
                button.tap()
    
        // Test 2 parte
        let collectionViewsQuery = app.collectionViews

        collectionViewsQuery/*@START_MENU_TOKEN@*/.buttons["katt, subst., husdjuret Felis ocreata domestica; kisse, gato"]/*[[".cells.buttons[\"katt, subst., husdjuret Felis ocreata domestica; kisse, gato\"]",".buttons[\"katt, subst., husdjuret Felis ocreata domestica; kisse, gato\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        
        app.navigationBars["_TtGC7SwiftUI19UIHosting"].buttons["Diccionary"].tap()
        
        
        /*
      
        if link.waitForExistence(timeout: 20) {
            link.tap()
        }
        */
          
        
    
        
        
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }

    func testLaunchPerformance() throws {
        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 7.0, *) {
            // This measures how long it takes to launch your application.
            measure(metrics: [XCTApplicationLaunchMetric()]) {
                XCUIApplication().launch()
            }
        }
    }
}
