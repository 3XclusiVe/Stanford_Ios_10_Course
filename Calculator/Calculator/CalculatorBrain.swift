//
//  CalculatorBrain.swift
//  Calculator
//
//    Created by CS193p Instructor. on 1/9/17
//  Copyright © 2017 Stanford University.
//  All rights reserved.
//

import Foundation

struct CalculatorBrain {

    private let formatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 6
        formatter.notANumberSymbol = ""
        formatter.groupingSeparator = " "
        formatter.locale = Locale.current
        return formatter
    }()

    private enum Operation {
        case nullary(Double, String)
        case unaryOperation((Double) -> Double, (String) -> String)
        case binaryOperation((Double, Double) -> Double, (String, String) -> String)
        case equals
    }

    private enum OperationStack {
        case operand(Double)
        case operation(String)
        case variable(String)
    }

    private var operationStack = [OperationStack]()

    mutating func setOperand(_ operand: Double) {
        operationStack.append(OperationStack.operand(operand))
    }

    mutating func setOperand(variable: String) {
        operationStack.append(OperationStack.variable(variable))
    }

    mutating func setOperand(symbol: String) {
        operationStack.append(OperationStack.operation(symbol))
    }

    mutating func undo() {
        if(!operationStack.isEmpty) {
            operationStack.removeLast()
        }
    }

    func evaluate(using variables: Dictionary<String, Double>? = nil) ->
        (result: Double?, isPending: Bool, description: String?, error: String?) {

            var accumulator: Double?
            var operationDescription: String?
            var pendingBinaryOperation: PendingBinaryOperation?

            var description: String? {
                if let binaryOperation = pendingBinaryOperation {
                    return binaryOperation.descriptionFunction(binaryOperation.firstOperandDescription,
                                                               operationDescription!)
                } else {
                    return operationDescription
                }
            }

            var result: Double? {
                if (pendingBinaryOperation != nil) && accumulator == nil {
                    return pendingBinaryOperation!.firstOperand
                } else {
                    return accumulator
                }
            }

            var resultIsPending: Bool {
                return pendingBinaryOperation != nil
            }

            func setOperand(_ operand: Double) {
                accumulator = operand
                operationDescription = formatter.string(from: NSNumber(value: operand)) ?? ""
            }

            func setOperand(variable: String) {
                accumulator = variables?[variable] ?? 0
                operationDescription = variable
            }

            func performOperation(_ symbol: String) {
                if let operation = operations[symbol] {
                    switch operation {
                    case let .nullary(value, _):
                        accumulator = value
                        operationDescription = symbol
                        break
                    case let .unaryOperation(function, descriptionFunction):
                        perform(unaryOperation: function)
                        operationDescription = descriptionFunction(operationDescription!)
                        break
                    case let .binaryOperation(function, descriptionFunction):
                        performPendingBinaryOperation()
                        pending(binaryOperation: function, descriptionFunction: descriptionFunction)
                        break
                    case .equals:
                        performPendingBinaryOperation()
                        break
                    }
                }
            }

            func perform(unaryOperation: (Double) -> Double) {
                guard accumulator != nil else { return }
                accumulator = unaryOperation(accumulator!)
            }

            func pending(binaryOperation: @escaping (Double, Double) -> Double,
                         descriptionFunction: @escaping (String, String) -> String) {
                guard accumulator != nil else { return }
                pendingBinaryOperation =
                    PendingBinaryOperation(function: binaryOperation,
                                           firstOperand: accumulator!,
                                           descriptionFunction: descriptionFunction,
                                           firstOperandDescription: operationDescription!)
                accumulator = nil
                operationDescription = ""
            }

            func performPendingBinaryOperation() {
                guard pendingBinaryOperation != nil && accumulator != nil else { return }

                accumulator = pendingBinaryOperation!.perform(with: accumulator!)
                operationDescription = pendingBinaryOperation!.makeDescription(with: operationDescription!)

                pendingBinaryOperation = nil
            }

            guard !operationStack.isEmpty else { return (nil, false, nil, nil) }
            pendingBinaryOperation = nil
            for operation in operationStack {
                switch operation {
                case let .operand(operand):
                    setOperand(operand)
                    break
                case let .operation(operation):
                    performOperation(operation)
                    break
                case let .variable(variable):
                    setOperand(variable: variable)
                    break
                }
            }

            return (result, resultIsPending, description, nil)
    }

    private var operations: [String: Operation] =
        [
            "π": Operation.nullary(Double.pi,
                                    "π"),
            "e": Operation.nullary(M_E,
                                   "e"),
            "√": Operation.unaryOperation(sqrt, { "√(" + $0 + ")" }),
            "cos": Operation.unaryOperation(cos, { "cos(" + $0 + ")" }),
            "±": Operation.unaryOperation({ -$0 }, { "±(" + $0 + ")" }),
            "×": Operation.binaryOperation({ $0 * $1 }, { $0 + "×" + $1 }),
            "÷": Operation.binaryOperation({ $0 / $1 }, { $0 + "/" + $1 }),
            "+": Operation.binaryOperation({ $0 + $1 }, { $0 + "+" + $1 }),
            "-": Operation.binaryOperation({ $0 - $1 }, { $0 + "-" + $1 }),
            "=": Operation.equals,
            "x^2": Operation.unaryOperation({ $0 * $0 }, { "(" + $0 + ")^2" }),
            "x^3": Operation.unaryOperation({ $0 * $0 * $0 }, { "(" + $0 + ")^3" }),
            "sin": Operation.unaryOperation(sin, { "sin(" + $0 + ")" }),
            "Random": Operation.nullary(Double.random(), "rand()")
    ]

    @available(iOS, deprecated, message: "Not supported")
    var description: String {
        return evaluate().description!
    }

    mutating func performOperation(_ symbol: String) {
        setOperand(symbol: symbol)
    }

    @available(iOS, deprecated, message: "Not supported")
    var resultIsPending: Bool {
        return evaluate().isPending
    }

    private struct PendingBinaryOperation {
        let function: (Double, Double) -> Double
        let firstOperand: Double
        let descriptionFunction: (String, String) -> String
        let firstOperandDescription: String

        func perform(with secondOperand: Double) -> Double {
            return function(firstOperand, secondOperand)
        }

        func makeDescription(with secondOperandDescription: String) -> String {
            return descriptionFunction(firstOperandDescription, secondOperandDescription)
        }
    }

    @available(iOS, deprecated, message: "Not supported")
    var result: Double? {
        return evaluate().result
    }

    mutating func clearAll() {
        operationStack.removeAll()
    }
}

public extension Double {
    /// SwiftRandom extension
    public static func random(lower: Double = 0, _ upper: Double = 100) -> Double {
        return (Double(arc4random()) / 0xFFFF_FFFF) * (upper - lower) + lower
    }
}
