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
    }

    private var axesDrawer = AxesDrawer()

}
