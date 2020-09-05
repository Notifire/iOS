//
//  CurvedTopView.swift
//  Notifire
//
//  Created by David Bielik on 27/08/2018.
//  Copyright © 2018 David Bielik. All rights reserved.
//

import UIKit

class CurvedTopView: ConstrainableView {

    // MARK: - Properties
    private static let expandedCurveMidXDistanceFromTop: CGFloat = 8
    private static let collapsedCurveMidXDistanceFromTop: CGFloat = 2
    private static let shapeLayerColor = UIColor.compatibleSystemBackground

    private var expandedCurvePath: CGPath!
    private var collapsedCurvePath: CGPath!
    private var shapeLayer = CAShapeLayer()
    private var isFirstAppearance = true

    // MARK: - Inherited
    override func setupSubviews() {
        super.setupSubviews()
        clipsToBounds = false

        layer.addSublayer(shapeLayer)
        shapeLayer.fillColor = CurvedTopView.shapeLayerColor.cgColor
        backgroundColor = CurvedTopView.shapeLayerColor
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        shapeLayer.frame = layer.bounds
        setupTopCurvePaths()
        setFirstPath()
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        if #available(iOS 13.0, *) {
            if traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
                shapeLayer.fillColor = CurvedTopView.shapeLayerColor.cgColor
                layoutIfNeeded()
            }
        }
    }

    // MARK: - Private
    private func setupTopCurvePaths() {
        let width = bounds.size.width

        let yOffset: CGFloat = 5 // prevents bottom line flickering
        let leftPoint = CGPoint(x: 0, y: 0)
        let midPoint = CGPoint(x: width/2, y: -CurvedTopView.collapsedCurveMidXDistanceFromTop*2)
        let midPointExpanded = CGPoint(x: width/2, y: -CurvedTopView.expandedCurveMidXDistanceFromTop*2)
        let rightPoint = CGPoint(x: width, y: 0)

        let pathWithMidPoint: ((CGPoint) -> UIBezierPath) = { middle in
            let path = UIBezierPath()
            path.move(to: leftPoint)
            path.addQuadCurve(to: rightPoint, controlPoint: middle)
            path.addLine(to: CGPoint(x: rightPoint.x, y: rightPoint.y+yOffset))
            path.addLine(to: CGPoint(x: leftPoint.x, y: leftPoint.y+yOffset))
            path.close()
            return path
        }

        let collapsedBezierPath = pathWithMidPoint(midPoint)
        let expandedBezierPath = pathWithMidPoint(midPointExpanded)

        expandedCurvePath = expandedBezierPath.cgPath
        collapsedCurvePath = collapsedBezierPath.cgPath
    }

    private func setFirstPath() {
        guard isFirstAppearance else { return }
        isFirstAppearance = false
        shapeLayer.path = collapsedCurvePath
    }

    // MARK: - Public
    public func switchPaths(expanded: Bool, duration: TimeInterval) {
        let newPath = expanded ? expandedCurvePath : collapsedCurvePath
        let pathAnimation = CABasicAnimation(keyPath: "path")
        pathAnimation.fromValue = shapeLayer.path
        pathAnimation.toValue = newPath
        pathAnimation.duration = duration
        pathAnimation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeOut)
        shapeLayer.path = newPath
        shapeLayer.add(pathAnimation, forKey: "animatePath")
    }

}
