//
//  GraphViewController.swift
//  Calculator
//
//  Created by Дмитрий on 22.09.17.
//
//

import UIKit

class GraphViewController: UIViewController {

    var function: ((Double) -> Double)? { didSet { updateUI() } }

    @IBOutlet weak var graphView: GraphView! {
        didSet {
            let panGestureRecognizer = UIPanGestureRecognizer(
                target: self, action: #selector(moveOrigin))
            graphView.addGestureRecognizer(panGestureRecognizer)

            let doubleTapGestureRecognizer = UITapGestureRecognizer(
                target: self, action: #selector(changeOrigin))
            doubleTapGestureRecognizer.numberOfTapsRequired = 2
            graphView.addGestureRecognizer(doubleTapGestureRecognizer)

            let pinchGestureRecognizer = UIPinchGestureRecognizer(
                target: self, action: #selector(changeScale))
            graphView.addGestureRecognizer(pinchGestureRecognizer)

            updateUI()
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
    }

    private func updateUI() {
        graphView?.function = self.function
    }

    @objc private func changeOrigin(byReactingTo gesture: UITapGestureRecognizer) {
        if gesture.state == .ended {
            graphView.origin = gesture.location(in: graphView)
        }
    }

    @objc private func moveOrigin(byReactingTo gesture: UIPanGestureRecognizer) {
        switch gesture.state {
        case .changed:
            let direction = gesture.translation(in: graphView)
            moveOriginTo(direction)
            gesture.setTranslation(CGPoint.zero, in: graphView)
        default:
            break
        }
    }

    @objc private func changeScale(byReactingTo gesture: UIPinchGestureRecognizer) {
        switch gesture.state {
        case .changed:
            graphView.scale *= gesture.scale
            gesture.scale = 1
        default:
            break
        }
    }

    private func moveOriginTo(_ direction: CGPoint) {
        graphView.origin = CGPoint(x: graphView.origin.x + direction.x,
                                   y: graphView.origin.y + direction.y)
    }

}
