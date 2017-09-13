//
//  CalculatorTests.swift
//  CalculatorTests
//
//  Created by Дмитрий on 10.09.17.
//

import XCTest
@testable import Calculator

class CalculatorBrainTests: XCTestCase {

    func testFunctionality() {
        var testBrain = CalculatorBrain()

        testBrain.setOperand(7)
        testBrain.performOperation("+")
        XCTAssertEqual(testBrain.evaluate().description, "7+")
        XCTAssertTrue(testBrain.evaluate().isPending)
        XCTAssertFalse(testBrain.evaluate().result != nil)

        testBrain.setOperand(9)
        XCTAssertEqual(testBrain.description, "7+9")
        XCTAssertTrue(testBrain.resultIsPending)
        XCTAssertEqual(testBrain.result, 9)

        testBrain.performOperation("=")
        XCTAssertEqual(testBrain.description, "7+9")
        XCTAssertFalse(testBrain.resultIsPending)
        XCTAssertEqual(testBrain.result, 16)

        testBrain.performOperation("√")
        XCTAssertEqual(testBrain.description, "√(7+9)")
        XCTAssertFalse(testBrain.resultIsPending)
        XCTAssertEqual(testBrain.result, 4)

        testBrain.performOperation("+")
        testBrain.setOperand(2)
        testBrain.performOperation("=")
        XCTAssertEqual(testBrain.description, "√(7+9)+2")
        XCTAssertFalse(testBrain.resultIsPending)
        XCTAssertEqual(testBrain.result, 6)
    }

    func testUnaryOperationWithOneNumber() {
        var testBrain = CalculatorBrain()

        testBrain.setOperand(7)
        testBrain.performOperation("+")
        testBrain.setOperand(9)
        testBrain.performOperation("√")
        XCTAssertEqual(testBrain.description, "7+√(9)")
        XCTAssertTrue(testBrain.resultIsPending)
        XCTAssertEqual(testBrain.result, 3)

        testBrain.performOperation("=")
        XCTAssertEqual(testBrain.description, "7+√(9)")
        XCTAssertFalse(testBrain.resultIsPending)
        XCTAssertEqual(testBrain.result, 10)

        testBrain.performOperation("+")
        testBrain.setOperand(6)
        testBrain.performOperation("+")
        testBrain.setOperand(3)
        testBrain.performOperation("=")
        XCTAssertEqual(testBrain.description, "7+√(9)+6+3")
        XCTAssertFalse(testBrain.resultIsPending)
        XCTAssertEqual(testBrain.result, 19)
    }

    func testCancel() {
        var testBrain = CalculatorBrain()

        testBrain.setOperand(5)
        testBrain.performOperation("+")
        testBrain.setOperand(6)
        testBrain.performOperation("=")
        testBrain.setOperand(76)
        XCTAssertEqual(testBrain.description, "76")
        XCTAssertFalse(testBrain.resultIsPending)
        XCTAssertEqual(testBrain.result, 76)
    }

    func testNullary() {
        var testBrain = CalculatorBrain()

        testBrain.setOperand(4)
        testBrain.performOperation("×")
        testBrain.performOperation("π")
        testBrain.performOperation("=")
        XCTAssertEqual(testBrain.description, "4×π")
        XCTAssertFalse(testBrain.resultIsPending)
        XCTAssertEqualWithAccuracy(testBrain.result!,
                                   12.5663706143592,
                                   accuracy: 0.0001)
    }
}
