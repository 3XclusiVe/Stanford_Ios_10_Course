//
//  GraphViewController.swift
//  Calculator
//
//  Created by Дмитрий on 22.09.17.
//
//

import UIKit

class GraphViewController: UIViewController {

    var function: ((Double) -> Double)? {didSet {updateUI()}}

    @IBOutlet weak var graphView: GraphView! {
        didSet {
            /** let panGestureRecognizer = UIPanGestureRecognizer(
             target: self, action: #selector(updateUI))
             graphView.addGestureRecognizer(panGestureRecognizer)

             let pinchGestureRecognizer = UIPinchGestureRecognizer(
             target: self, action: #selector(updateUI))
             graphView.addGestureRecognizer(pinchGestureRecognizer)

             let tapGestureRecognizer = UITapGestureRecognizer(
             target: self, action: #selector(updateUI))
             tapGestureRecognizer.numberOfTouchesRequired = 2
             graphView.addGestureRecognizer(tapGestureRecognizer)
             **/
        }
    }

    private func updateUI() {
        graphView.function = self.function
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.function = {sin($0)}
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    /*
     // MARK: - Navigation

     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */

}
