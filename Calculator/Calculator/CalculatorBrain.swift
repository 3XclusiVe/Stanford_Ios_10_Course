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
        case unaryOperation((Double) -> Double,
            (String) -> String,
            ((Double) -> (String?))?)
        case binaryOperation((Double, Double) -> Double,
            (String, String) -> String,
            ((Double, Double) -> (String?))?)
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
            var error: String?

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
                    case let .unaryOperation(function, descriptionFunction, errorHandler):
                        perform(unaryOperation: function, validator: errorHandler)
                        operationDescription = descriptionFunction((operationDescription!))
                        break
                    case let .binaryOperation(function, descriptionFunction, errorHandler):
                        performPendingBinaryOperation()
                        pending(binaryOperation: function, descriptionFunction: descriptionFunction, validator: errorHandler)
                        break
                    case .equals:
                        performPendingBinaryOperation()
                        break
                    }
                }
            }

            func perform(unaryOperation: (Double) -> Double, validator: (((Double) -> (String?))?)) {
                guard accumulator != nil else { return }
                error = validator?(accumulator!)
                accumulator = unaryOperation(accumulator!)
            }

            func pending(binaryOperation: @escaping (Double, Double) -> Double,
                         descriptionFunction: @escaping (String, String) -> String,
                         validator: ((Double, Double) -> (String?))?) {
                guard accumulator != nil else { return }
                pendingBinaryOperation =
                    PendingBinaryOperation(function: binaryOperation,
                                           firstOperand: accumulator!,
                                           descriptionFunction: descriptionFunction,
                                           firstOperandDescription: operationDescription!,
                                           validator: validator)
                accumulator = nil
                operationDescription = ""
                error = nil
            }

            func performPendingBinaryOperation() {
                guard pendingBinaryOperation != nil && accumulator != nil else { return }

                (accumulator!, error) = pendingBinaryOperation!.perform(with: accumulator!)
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

            return (result, resultIsPending, description, error)
    }

    private var operations: [String: Operation] =
        [
            "π": Operation.nullary(Double.pi,
                                    "π"),
            "e": Operation.nullary(M_E,
                                   "e"),
            "√": Operation.unaryOperation(sqrt, { "√(" + $0 + ")" }, {$0 < 0 ? "√ отриц. числа" : nil}),
            "cos": Operation.unaryOperation(cos, { "cos(" + $0 + ")" }, nil),
            "±": Operation.unaryOperation({ -$0 }, { "±(" + $0 + ")" }, nil),
            "×": Operation.binaryOperation({ $0 * $1 }, { $0 + "×" + $1 }, nil),
            "÷": Operation.binaryOperation({ $0 / $1 }, { $0 + "/" + $1 }, {$1 == 0.0 ? "деление на ноль" : nil}),
            "+": Operation.binaryOperation({ $0 + $1 }, { $0 + "+" + $1 }, nil),
            "-": Operation.binaryOperation({ $0 - $1 }, { $0 + "-" + $1 }, nil),
            "=": Operation.equals,
            "x^2": Operation.unaryOperation({ $0 * $0 }, { "(" + $0 + ")^2" }, nil),
            "x^3": Operation.unaryOperation({ $0 * $0 * $0 }, { "(" + $0 + ")^3" }, nil),
            "sin": Operation.unaryOperation(sin, { "sin(" + $0 + ")" }, nil),
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
        let validator: ((Double, Double) -> (String?))?

        func perform(with secondOperand: Double) -> (Double, String?) {
            return (function(firstOperand, secondOperand), validator?(firstOperand, secondOperand))
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
