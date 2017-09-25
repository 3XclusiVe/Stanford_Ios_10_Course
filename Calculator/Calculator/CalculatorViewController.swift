//
//  ViewController.swift
//  Calculator
//
//  Created by CS193p Instructor. on 1/9/17
//  Copyright © 2017 Stanford University.
//  All rights reserved.
//

import UIKit

class CalculatorViewController: UIViewController {

    @IBOutlet weak var display: UILabel!
    @IBOutlet weak var history: UILabel!
    @IBOutlet weak var variableDisply: UILabel!

    private let formatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 6
        formatter.numberStyle = .decimal
        formatter.notANumberSymbol = ""
        formatter.groupingSeparator = " "
        formatter.locale = Locale.current
        return formatter
    }()

    var userInTheMiddleOfTyping = false

    @IBAction func touchDigit(_ sender: UIButton) {
        let digit = sender.currentTitle!
        if userInTheMiddleOfTyping {
            let textCurrentlyInDisplay = display.text!
            if digit != "." || !textCurrentlyInDisplay.contains(".") {
                display.text = textCurrentlyInDisplay + digit
            }
        } else {
            display.text = digit
            userInTheMiddleOfTyping = true
        }
    }

    var displayValue: Double? {
        get {
            return Double(display.text!)
        }
        set {
            if newValue == nil {
                display.text = " "
            } else {
                display.text = formatter.string(from: NSNumber(value: newValue!))
            }
        }
    }

    var currentVariableValue: Double? {
        get {
            return Double(variableDisply.text!)!
        }
        set {
            if newValue == nil {
                variableDisply.text = " "
            } else {
                variableDisply.text = formatter.string(from: NSNumber(value: newValue!))
            }
        }
    }

    private var brain = CalculatorBrain()
    private var variablesValues = [String: Double]()

    @IBAction func performOPeration(_ sender: UIButton) {
        if userInTheMiddleOfTyping {
            if(displayValue != nil) {
                brain.setOperand(displayValue!)
            }
            userInTheMiddleOfTyping = false
        }
        if let mathematicalSymbol = sender.currentTitle {
            brain.performOperation(mathematicalSymbol)
        }
        updateDisplay()
    }

    @IBAction func clearDisplay(_: UIButton) {
        brain.clearAll()
        variablesValues.removeAll()
        updateDisplay()
    }

    @IBAction func onTapBackspace(_: UIButton) {
        if userInTheMiddleOfTyping {

            guard !display.text!.isEmpty else { return }
            display.text = String (display.text!.characters.dropLast())
            if display.text!.isEmpty {
                userInTheMiddleOfTyping = false
                updateDisplay()
            }

        } else {
            brain.undo()
            updateDisplay()
        }
    }

    private func updateDisplay() {

        let evaluation = brain.evaluate(using: variablesValues)

        if let result = evaluation.result {
            displayValue = result
        } else {
            displayValue = nil
        }
        if let history = evaluation.description {
            self.history.text = history +
                (evaluation.isPending ? " ..." : " =")
        } else {
            history.text = ""
        }

        if let error = evaluation.error {
            display.text = error
        }

        currentVariableValue = variablesValues["M"]
    }

    @IBAction func pushVariable(_ sender: UIButton) {
        brain.setOperand(variable: sender.currentTitle!)
        updateDisplay()
    }

    @IBAction func setVariable(_ sender: UIButton) {
        userInTheMiddleOfTyping = false
        let variableSymbol =
            String((sender.currentTitle!).characters.dropFirst())

        variablesValues[variableSymbol] = displayValue
        updateDisplay()

    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)

        var destination = segue.destination
        if let navigationController = destination as? UINavigationController {
            destination = navigationController.visibleViewController ?? destination
        }

        if let identifier = segue.identifier,
            identifier == Storyboard.ShowGraph {
            if let graphViewController = destination as? GraphViewController {
                graphViewController.function = { [weak self = self](x) in
                    self?.variablesValues["M"] = x
                    let evaluation = self?.brain.evaluate(using: self?.variablesValues)
                    return (evaluation?.result)!
                }
                if let description = brain.evaluate(using: variablesValues).description {
                    graphViewController.navigationItem.title = "y=" + description
                }
            }
        }
    }

    override func shouldPerformSegue(withIdentifier identifier: String?,
                                     sender: Any?) -> Bool {
        if identifier == Storyboard.ShowGraph,
            brain.evaluate(using: variablesValues).isPending {
            return false
        }
        return true
    }
}
