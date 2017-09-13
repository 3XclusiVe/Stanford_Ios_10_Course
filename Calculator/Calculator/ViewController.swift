//
//  ViewController.swift
//  Calculator
//
//  Created by CS193p Instructor. on 1/9/17
//  Copyright © 2017 Stanford University.
//  All rights reserved.
//

import UIKit
// TODO: убрать баг после нажатия C и ввода числа
class ViewController: UIViewController {

    @IBOutlet weak var display: UILabel!
    @IBOutlet weak var history: UILabel!

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

    var displayValue: Double {
        get {
            return Double(display.text!)!
        }
        set {
            display.text = String(newValue)
        }
    }

    private var brain = CalculatorBrain()
    private var variablesValues = [String: Double]()

    @IBAction func performOPeration(_ sender: UIButton) {
        if userInTheMiddleOfTyping {
            brain.setOperand(displayValue)
            userInTheMiddleOfTyping = false
        }
        if let mathematicalSymbol = sender.currentTitle {
            brain.performOperation(mathematicalSymbol)
        }
        updateDisplay()
    }

    @IBAction func clearDisplay(_: UIButton) {
        brain.clearAll()
        updateDisplay()
    }

    @IBAction func onTapBackspace(_: UIButton) {
        // TODO: добавить инициализацию форматтера в класс использовать для вывода на дисплей
        if userInTheMiddleOfTyping {
            let formatter = NumberFormatter()
            formatter.minimumFractionDigits = 0
            formatter.maximumFractionDigits = 2
            var displayString = formatter.string(from: NSNumber(value: displayValue))
            displayString!.remove(at: (displayString?.startIndex)!)
            displayValue = Double(displayString ?? "0") ?? 0
        }
    }

    private func updateDisplay() {

        if let result = brain.result {
            displayValue = result
        }

        history.text = brain.description +
            (brain.resultIsPending ? " ..." : " =")

        if brain.description.isEmpty && brain.result == nil {
            history.text = ""
            displayValue = 0
        }
    }

    @IBAction func pushVariable(_ sender: UIButton) {

    }

    @IBAction func setVariable(_ sender: UIButton) {
        userInTheMiddleOfTyping = false
        let variableSymbol =
            String((sender.currentTitle!).characters.dropFirst())

        variablesValues[variableSymbol] = displayValue

    }
}