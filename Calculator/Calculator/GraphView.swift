//
//  GraphView.swift
//  Calculator
//
//  Created by Дмитрий on 21.09.17.
//
//

import UIKit

@IBDesignable
class GraphView: UIView {

    var function: ((Double) -> Double)? = { sin($0) / cos($0) } { didSet { setNeedsDisplay() } }

    @IBInspectable
    var minimumPointsPerHashmark: CGFloat = 40 { didSet { setNeedsDisplay() } }

    @IBInspectable
    var scale: CGFloat = 50 { didSet { setNeedsDisplay() } }

    @IBInspectable
    var axesColor: UIColor = UIColor.blue { didSet { setNeedsDisplay() } }

    @IBInspectable
    var lineWidth: CGFloat = 3 { didSet { setNeedsDisplay() } }

    @IBInspectable
    var lineColor: UIColor = UIColor.black { didSet { setNeedsDisplay() } }

    private var graphOrigin: CGPoint?

    var origin: CGPoint {
        get {
            return graphOrigin ?? CGPoint(x: self.bounds.midX, y: self.bounds.midY)
        }
        set {
            graphOrigin = newValue
            setNeedsDisplay()
        }
    }

    override func draw(_ rect: CGRect) {

        let origin = self.origin
        axesDrawer.color = axesColor
        axesDrawer.contentScaleFactor = contentScaleFactor
        axesDrawer.minimumPointsPerHashmark = minimumPointsPerHashmark
        axesDrawer.drawAxes(in: bounds,
                            origin: origin,
                            pointsPerUnit: scale)

        drawFunctionGraph(inRectangle: rect, fromOrigin: origin, withScale: scale)
    }

    private var axesDrawer = AxesDrawer()

    private func drawFunctionGraph(inRectangle rect: CGRect,
                                   fromOrigin origin: CGPoint,
                                   withScale scale: CGFloat) {

        guard (function != nil) else {
            return
        }

        let path = UIBezierPath()
        var isFirstPoint = true
        var currentYUnit: CGFloat = 0.0
        var lastYUnit: CGFloat = 0.0

        func isAsymptote() -> Bool {
            return abs(lastYUnit - currentYUnit) >
                max(bounds.width * 1.5, bounds.height * 1.5)
        }

        func fromUnitToXValue(_ unit: CGFloat) -> Double {
            return Double((unit - origin.x) / scale)
        }

        func fromYValueToUnit(_ value: Double) -> CGFloat {
            return origin.y - (CGFloat(value) * scale)
        }

        func addToPath(_ point: CGPoint) {
            if isFirstPoint {
                path.move(to: point)
                isFirstPoint = false
            } else {
                if(isAsymptote()) {
                    isFirstPoint = true
                    path.move(to: point)
                } else {
                    path.addLine(to: point)
                }
            }
        }

        let lastXPixel = Int(rect.size.width * contentScaleFactor)

        for xPixel in 0...lastXPixel {
            let xUnit = CGFloat (xPixel) / contentScaleFactor
            let x = fromUnitToXValue(xUnit)
            let y = function!(x)

            guard (y.isFinite) else { continue }

            let yUnit = fromYValueToUnit(y)
            lastYUnit = currentYUnit
            currentYUnit = yUnit

            let point = CGPoint(x: xUnit, y: yUnit)
            addToPath(point)
        }

        self.lineColor.setStroke()
        path.lineWidth = self.lineWidth
        path.stroke()
    }

}
