//
//  CalculatorUITests.swift
//  CalculatorUITests
//
//  Created by Дмитрий on 10.09.17.
//

import XCTest
@testable import Calculator

class CalculatorUITests: XCTestCase {

    override func setUp() {
        super.setUp()

        continueAfterFailure = false
        XCUIApplication().launch()
    }

    func testExample() {

        let app = XCUIApplication()
        app.buttons["4"].tap()

        let button = app.buttons["+"]
        button.tap()

        let button2 = app.buttons["2"]
        button2.tap()
        button.tap()
        app.buttons["9"].tap()
        app.buttons["√"].tap()
        button.tap()
        button2.tap()
        app.buttons["="].tap()

        XCTAssert(app.staticTexts["11.0"].exists)
    }
}
