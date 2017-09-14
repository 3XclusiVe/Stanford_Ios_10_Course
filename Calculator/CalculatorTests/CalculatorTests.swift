//
//  CalculatorTests.swift
//  CalculatorTests
//
//  Created by Дмитрий on 10.09.17.
//

import XCTest
@testable import Calculator

class CalculatorBrainTests: XCTestCase {

    func testPerformOperation() {
        var testBrain = CalculatorBrain()

        testBrain.setOperand(4)
        testBrain.performOperation("-")
        testBrain.setOperand(10)
        testBrain.performOperation("=")
        XCTAssertEqual(testBrain.evaluate().result, -6)

        testBrain.setOperand(81)
        testBrain.performOperation("√")
        XCTAssertEqual(testBrain.evaluate().result, 9)

        testBrain.setOperand(12)
        testBrain.performOperation("±")
        XCTAssertEqual(testBrain.evaluate().result, -12)

        testBrain.setOperand(5)
        testBrain.performOperation("×")
        testBrain.setOperand(5)
        testBrain.performOperation("=")
        XCTAssertEqual(testBrain.evaluate().result, 25)

        testBrain.setOperand(4)
        testBrain.performOperation("+")
        testBrain.setOperand(9)
        testBrain.performOperation("=")
        XCTAssertEqual(testBrain.evaluate().result, 13)

        testBrain.setOperand(6)
        testBrain.performOperation("÷")
        testBrain.setOperand(2)
        testBrain.performOperation("=")
        XCTAssertEqual(testBrain.evaluate().result, 3)

        testBrain.performOperation("π")
        testBrain.performOperation("cos")
        XCTAssertEqual(testBrain.evaluate().result, -1)
    }

    func testAdditionalOperations() {
        var testBrain = CalculatorBrain()

        testBrain.setOperand(0)
        testBrain.performOperation("sin")
        XCTAssertEqual(testBrain.evaluate().result, 0)

        testBrain.setOperand(0)
        testBrain.performOperation("cos")
        XCTAssertEqual(testBrain.evaluate().result, 1)

        testBrain.setOperand(-9)
        testBrain.performOperation("x^2")
        XCTAssertEqual(testBrain.evaluate().result, 81)

        testBrain.setOperand(-4)
        testBrain.performOperation("x^3")
        XCTAssertEqual(testBrain.evaluate().result, -64)
    }

    func testResultIsPending() {
        var testBrain = CalculatorBrain()

        testBrain.setOperand(4)
        XCTAssertFalse(testBrain.evaluate().isPending)
        testBrain.performOperation("+")
        XCTAssertTrue(testBrain.evaluate().isPending)
        testBrain.setOperand(9)
        testBrain.performOperation("=")
        XCTAssertFalse(testBrain.evaluate().isPending)
        XCTAssertEqual(testBrain.evaluate().result, 13)
    }

    func testMultipleOperations() {
        var testBrain = CalculatorBrain()

        // 6 x 5 x 4 x 3 = will work
        testBrain.setOperand(6)
        XCTAssertFalse(testBrain.evaluate().isPending)
        testBrain.performOperation("×")
        XCTAssertTrue(testBrain.evaluate().isPending)
        testBrain.setOperand(5)
        testBrain.performOperation("×")
        XCTAssertTrue(testBrain.evaluate().isPending)
        testBrain.setOperand(4)
        testBrain.performOperation("×")
        XCTAssertTrue(testBrain.evaluate().isPending)
        testBrain.setOperand(3)
        testBrain.performOperation("=")
        XCTAssertFalse(testBrain.evaluate().isPending)
        XCTAssertEqual(testBrain.evaluate().result, 360)
    }

    func testDescription() {
        var testBrain = CalculatorBrain()

        // a. touching 7 + would show “7 + ...” (with 7 still in the display)
        testBrain.setOperand(7)
        testBrain.performOperation("+")
        XCTAssertEqual(testBrain.evaluate().description, "7+")
        XCTAssertTrue(testBrain.evaluate().isPending)
        XCTAssertFalse(testBrain.evaluate().result != nil)

        // b. 7 + 9 would show “7 + ...” (9 in the display)
        // no operation button touched, so operand is not send to model

        // c. 7 + 9 = would show “7 + 9 =” (16 in the display)
        testBrain.setOperand(9)
        testBrain.performOperation("=")
        XCTAssertEqual(testBrain.evaluate().description, "7+9")
        XCTAssertFalse(testBrain.evaluate().isPending)
        XCTAssertEqual(testBrain.evaluate().result, 16.0)

        // d. 7 + 9 = √ would show “√(7 + 9) =” (4 in the display)
        testBrain.performOperation("√")
        XCTAssertEqual(testBrain.evaluate().description, "√(7+9)")
        XCTAssertFalse(testBrain.evaluate().isPending)
        XCTAssertEqual(testBrain.evaluate().result, 4.0)

        // e. 7 + 9 = √ + 2 = would show “√(7 + 9) + 2 =” (6 in the display)
        testBrain.performOperation("+")
        testBrain.setOperand(2)
        testBrain.performOperation("=")
        XCTAssertEqual(testBrain.evaluate().description, "√(7+9)+2")
        XCTAssertFalse(testBrain.evaluate().isPending)
        XCTAssertEqual(testBrain.evaluate().result, 6.0)

        // f. 7 + 9 √ would show “7 + √(9) ...” (3 in the display)
        testBrain.setOperand(7)
        testBrain.performOperation("+")
        testBrain.setOperand(9)
        testBrain.performOperation("√")
        XCTAssertEqual(testBrain.evaluate().description, "7+√(9)")
        XCTAssertTrue(testBrain.evaluate().isPending)
        XCTAssertEqual(testBrain.evaluate().result, 3.0)

        // g. 7 + 9 √ = would show “7 + √(9) =“ (10 in the display)
        testBrain.performOperation("=")
        XCTAssertEqual(testBrain.evaluate().description, "7+√(9)")
        XCTAssertFalse(testBrain.evaluate().isPending)
        XCTAssertEqual(testBrain.evaluate().result, 10.0)

        // h. 7 + 9 = + 6 = + 3 = would show “7 + 9 + 6 + 3 =” (25 in the display)
        testBrain.setOperand(7)
        testBrain.performOperation("+")
        testBrain.setOperand(9)
        testBrain.performOperation("=")
        testBrain.performOperation("+")
        testBrain.setOperand(6)
        testBrain.performOperation("=")
        testBrain.performOperation("+")
        testBrain.setOperand(3)
        testBrain.performOperation("=")
        XCTAssertEqual(testBrain.evaluate().description, "7+9+6+3")
        XCTAssertFalse(testBrain.evaluate().isPending)
        XCTAssertEqual(testBrain.evaluate().result, 25.0)

        // i. 7 + 9 = √ 6 + 3 = would show “6 + 3 =” (9 in the display)
        testBrain.setOperand(7)
        testBrain.performOperation("+")
        testBrain.setOperand(9)
        testBrain.performOperation("=")
        testBrain.performOperation("√")
        testBrain.setOperand(6)
        testBrain.performOperation("+")
        testBrain.setOperand(3)
        testBrain.performOperation("=")
        XCTAssertEqual(testBrain.evaluate().description, "6+3")
        XCTAssertFalse(testBrain.evaluate().isPending)
        XCTAssertEqual(testBrain.evaluate().result, 9.0)

        // j. 5 + 6 = 7 3 would show “5 + 6 =” (73 in the display)
        testBrain.setOperand(5)
        testBrain.performOperation("+")
        testBrain.setOperand(6)
        testBrain.performOperation("=")
        XCTAssertEqual(testBrain.evaluate().description, "5+6")
        XCTAssertFalse(testBrain.evaluate().isPending)
        XCTAssertEqual(testBrain.evaluate().result, 11.0)

        // k. 4 × π = would show “4 × π =“ (12.5663706143592 in the display)
        testBrain.setOperand(4)
        testBrain.performOperation("×")
        testBrain.performOperation("π")
        testBrain.performOperation("=")
        XCTAssertEqual(testBrain.evaluate().description, "4×π")
        XCTAssertFalse(testBrain.evaluate().isPending)
        XCTAssertEqualWithAccuracy(testBrain.evaluate().result!,
                                   12.5663706143592,
                                   accuracy: 0.0001)

    }
}
