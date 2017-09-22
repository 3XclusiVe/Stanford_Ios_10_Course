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

    var function: ((Double) -> Double)? {didSet {setNeedsDisplay()}}

    @IBInspectable
    var minimumPointsPerHashmark: CGFloat = 40 {didSet {setNeedsDisplay()}}

    @IBInspectable
    var axesColor: UIColor = UIColor.blue {didSet {setNeedsDisplay()}}

    @IBInspectable
    var pointsPerUnit: CGFloat = 1 {didSet {setNeedsDisplay()}}

    override func draw(_ rect: CGRect) {

        let origin = CGPoint(x: self.bounds.midX, y:self.bounds.midY)
        axesDrawer.color = axesColor
        axesDrawer.contentScaleFactor = contentScaleFactor
        axesDrawer.minimumPointsPerHashmark = minimumPointsPerHashmark
        axesDrawer.drawAxes(in: bounds,
                            origin: origin,
                            pointsPerUnit: pointsPerUnit)

        drawFunctionGraph(inRectangle: rect, fromOrigin: origin, withScale: 1)
    }

    private var axesDrawer = AxesDrawer()

    private func drawFunctionGraph(inRectangle rect: CGRect,
                                   fromOrigin origin: CGPoint,
                                   withScale scale: CGFloat) {

        guard (function != nil) else {
            return
        }

        let path = UIBezierPath()
        var isFirstPoint = false

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
                path.addLine(to: point)
            }
        }

        let lastXPixel = Int(rect.size.width * contentScaleFactor)

        for xPixel in 0...lastXPixel {
            let xUnit = CGFloat (xPixel) / contentScaleFactor
            let x = fromUnitToXValue(xUnit)
            let y = function!(x)
            let yUnit = fromYValueToUnit(y)

            let point = CGPoint(x:xUnit, y:yUnit)

            addToPath(point)
        }

        UIColor.black.setStroke()
        path.lineWidth = 3.0
        path.stroke()
    }

}
