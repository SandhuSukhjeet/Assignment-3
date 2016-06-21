//
//  GraphView.swift
//  GraphingCalculator
//
//  Created by sukhjeet singh sandhu on 23/06/16.
//  Copyright © 2016 sukhjeet singh sandhu. All rights reserved.
//

import UIKit
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


protocol GraphViewDataSource: class {
    func y(_ x: Double) -> CGFloat?
}

class GraphView: UIView {

    fileprivate let colorOfAxes = UIColor.blue
    fileprivate let colorOfGraphLine = UIColor.black
    fileprivate let lineWidth: CGFloat = 2
    fileprivate let noOfCoordinatesOnAxis = 6
    fileprivate var scale: CGFloat = 1 { didSet { setNeedsDisplay() } }
    fileprivate var graphCenter: CGPoint {
        get {
            return convert(center, from: superview)
        }
        set {
            origin = newValue
        }
    }
    fileprivate var origin = CGPoint.zero
    fileprivate var xAxisLength: CGFloat {
        return bounds.size.width / 2 * scale
    }
    fileprivate var yAxisLength: CGFloat {
        return bounds.size.height / 2 * scale
    }
    fileprivate var distanceOfACoordinateFromOtherOnXAxis: CGFloat {
        return xAxisLength / CGFloat(noOfCoordinatesOnAxis)
    }
    fileprivate var distanceOfACoordinateFromOtherOnYAxis: CGFloat {
        return yAxisLength / CGFloat(noOfCoordinatesOnAxis)
    }
    var graphDrawn = false
    weak var dataSource: GraphViewDataSource?
    
    override func draw(_ rect: CGRect) {
        if !graphDrawn {
            origin = graphCenter
            graphDrawn = true
        }
        drawAxes()
        for i in -6...6 {
            putCoordinatesOnAxes(CGFloat(i))
        }
        drawGraph()
    }

    fileprivate func drawAxes() {
        let yAxis = UIBezierPath()
        yAxis.move(to: CGPoint(x: origin.x, y: self.bounds.minY))
        yAxis.addLine(to: CGPoint(x: self.origin.x, y: self.bounds.maxY))
        colorOfAxes.set()
        yAxis.lineWidth = lineWidth
        yAxis.stroke()

        let xAxis = UIBezierPath()
        xAxis.move(to: CGPoint(x: self.bounds.minX, y: origin.y))
        xAxis.addLine(to: CGPoint(x: self.bounds.maxX, y: origin.y))
        colorOfAxes.set()
        xAxis.lineWidth = lineWidth
        xAxis.stroke()
    }

    fileprivate func putCoordinatesOnAxes(_ coordinateNumber: CGFloat) {
        let centerOfCoordinateOnXAxis = CGPoint(x: origin.x + (distanceOfACoordinateFromOtherOnXAxis * coordinateNumber), y: origin.y)
        let pathOfCoordinateOnXAxis = UIBezierPath(arcCenter: centerOfCoordinateOnXAxis, radius: 1.5, startAngle: 0, endAngle: CGFloat(M_PI * 2), clockwise: true)
        pathOfCoordinateOnXAxis.stroke()

        let centerOfCoordinateOnYAxis = CGPoint(x: origin.x, y: origin.y + (distanceOfACoordinateFromOtherOnYAxis * coordinateNumber))
        let pathOfCoordinateOnYAxis = UIBezierPath(arcCenter: centerOfCoordinateOnYAxis, radius: 1.5, startAngle: 0, endAngle: CGFloat(M_PI * 2), clockwise: true)
        pathOfCoordinateOnYAxis.stroke()
    }

    fileprivate func drawGraph() {
        var firstValue = true
        let path = UIBezierPath()
        let perfectScale = calculatePerfectScale()
        for i in stride(from: (-6.0), to: 6.0, by: 0.06) {
            let x = i * Double(720 / noOfCoordinatesOnAxis) // creating graph from -720 to 720
            if let yCoordinate = dataSource?.y(x) {
                if !yCoordinate.isNormal && !yCoordinate.isZero {
                    firstValue = true
                    continue
                }
                if firstValue {
                    path.move(to: CGPoint(x: origin.x + (CGFloat(i) * distanceOfACoordinateFromOtherOnXAxis), y: origin.y - (yCoordinate * distanceOfACoordinateFromOtherOnYAxis * perfectScale)))
                    firstValue = false
                } else {
                    path.addLine(to: CGPoint(x: origin.x + (CGFloat(i) * distanceOfACoordinateFromOtherOnXAxis), y: origin.y - (yCoordinate * distanceOfACoordinateFromOtherOnYAxis * perfectScale)))
                }
            } else {
                firstValue = true
            }
        }
        path.lineWidth = lineWidth
        colorOfGraphLine.set()
        path.stroke()
    }

    fileprivate func calculatePerfectScale() -> CGFloat {
        var max: CGFloat = 0
        var perfectScale:CGFloat = 1
        for i in stride(from: (-720.0), to: 720.0, by: 120) {
            let y = dataSource?.y(i)
            if y > max {
                max = y!
            }
        }
        if max > CGFloat(noOfCoordinatesOnAxis) {
            perfectScale = 1 / ceil(max / CGFloat(noOfCoordinatesOnAxis))
        }
        return perfectScale
    }

    func zoom(_ gesture: UIPinchGestureRecognizer) {
        switch gesture.state {
        case .changed, .ended:
            scale *= gesture.scale
            gesture.scale = 1.0
        default:
            break
        }
    }

    func moveCenter(_ gesture: UITapGestureRecognizer) {
        if gesture.state == .ended {
            graphCenter = gesture.location(in: self)
            setNeedsDisplay()
        }
    }

    func moveGraph(_ gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: self)
        let x = origin.x + translation.x
        let y = origin.y + translation.y
        graphCenter = CGPoint(x: x, y: y)
        gesture.setTranslation(CGPoint.zero, in: self)
        setNeedsDisplay()
    }
}
