//
//  GraphViewController.swift
//  GraphingCalculator
//
//  Created by sukhjeet singh sandhu on 22/06/16.
//  Copyright © 2016 sukhjeet singh sandhu. All rights reserved.
//

import UIKit

class GraphViewController: UIViewController {

    fileprivate let brain = CalculatorBrain()
    fileprivate var graphView = GraphView()
    var operation: AnyObject? = nil

    override func viewDidLoad() {
        super.viewDidLoad()
        addGraphView()
        graphView.dataSource = self
        graphView.addGestureRecognizer(UIPinchGestureRecognizer(target: graphView, action: #selector(graphView.zoom)))
        graphView.addGestureRecognizer(UITapGestureRecognizer(target: graphView, action: #selector(graphView.moveCenter)))
        graphView.addGestureRecognizer(UIPanGestureRecognizer(target: graphView, action: #selector(graphView.moveGraph(_:))))
    }

    fileprivate func addGraphView() {
        var heightOfExtendedEdges: CGFloat {
            if let navigationBarHeight = navigationController?.navigationBar.frame.size.height {
                return navigationBarHeight + UIApplication.shared.statusBarFrame.size.height
            } else {
                return UIApplication.shared.statusBarFrame.size.height
            }
        }
        graphView.translatesAutoresizingMaskIntoConstraints = false
        graphView.backgroundColor = .white

        view.addSubview(graphView)

        view.addConstraint(NSLayoutConstraint(item: graphView, attribute: .top, relatedBy: .equal, toItem: view, attribute: .top, multiplier: 1.0, constant: heightOfExtendedEdges + 8.0))
        view.addConstraint(NSLayoutConstraint(item: graphView, attribute: .leading, relatedBy: .equal, toItem: view, attribute: .leading, multiplier: 1.0, constant: 8.0))
        view.addConstraint(NSLayoutConstraint(item: graphView, attribute: .trailing, relatedBy: .equal, toItem: view, attribute: .trailing, multiplier: 1.0, constant: -8.0))
        view.addConstraint(NSLayoutConstraint(item: graphView, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1.0, constant: -8.0))
    }

    override func didRotate(from fromInterfaceOrientation: UIInterfaceOrientation) {
        graphView.graphDrawn = false
        graphView.setNeedsDisplay()
    }
}

extension GraphViewController: GraphViewDataSource {
    func y(_ x: Double) -> CGFloat? {
        brain.variableValues["M"] = x
        if let operation = operation {
            brain.program = operation
            return CGFloat(brain.result)
        } else {
            return nil
        }
    }
}
