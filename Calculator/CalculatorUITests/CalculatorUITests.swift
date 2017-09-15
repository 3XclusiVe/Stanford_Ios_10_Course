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

    func testVariables() {
        let app = XCUIApplication()

        app.buttons["9"].tap()
        app.buttons["+"].tap()
        app.buttons["M"].tap()
        app.buttons["="].tap()
        app.buttons["√"].tap()
        XCTAssert(app.staticTexts["√(9+M) ="].exists)
        XCTAssert(app.staticTexts["3"].exists)

        app.buttons["7"].tap()
        app.buttons["→M"].tap()
        XCTAssert(app.staticTexts["√(9+M) ="].exists)
        XCTAssert(app.staticTexts["4"].exists)

        app.buttons["+"].tap()
        app.buttons["1"].tap()
        app.buttons["4"].tap()
        app.buttons["="].tap()
        XCTAssert(app.staticTexts["√(9+M)+14 ="].exists)
        XCTAssert(app.staticTexts["18"].exists)

    }
}
