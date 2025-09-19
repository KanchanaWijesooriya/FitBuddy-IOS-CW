//
//  FitBuddyUITests.swift
//  FitBuddyUITests
//
//  Created by Chanuka Wijesooriya on 2025-08-24.
//

import XCTest

final class FitBuddyUITests: XCTestCase {

    override func setUpWithError() throws {

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

    }

    override func tearDownWithError() throws {
    }

    @MainActor
    func testExample() throws {
        // UI tests must launch the application that they test.
        let app = XCUIApplication()
        app.launch()

        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }

    @MainActor
    func testLaunchPerformance() throws {
        // This measures how long it takes to launch your application.
        measure(metrics: [XCTApplicationLaunchMetric()]) {
            XCUIApplication().launch()
        }
    }
}
