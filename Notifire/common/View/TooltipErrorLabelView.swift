//
//  TooltipErrorLabelView.swift
//  Notifire
//
//  Created by David Bielik on 30/03/2021.
//  Copyright © 2021 David Bielik. All rights reserved.
//

import UIKit

class TooltipErrorLabelView: ConstrainableView {

    // MARK: - Properties
    // MARK: Static
    static let toolTipWidth: CGFloat = 10.0
    static let toolTipHeight: CGFloat = 4.0
    static let tooltipColor: UIColor = .compatibleRed

    // MARK: UI
    lazy var errorLabel: UILabel = {
        let label = UILabel(style: .secondary)
        label.textColor = .white
        label.adjustsFontSizeToFitWidth = true
        return label
    }()

    // MARK: - Overrides
    override func setupSubviews() {
        directionalLayoutMargins = NSDirectionalEdgeInsets(top: Size.standardMargin, leading: Size.standardMargin, bottom: Size.standardMargin, trailing: Size.standardMargin)

        add(subview: errorLabel)
        NSLayoutConstraint.activate([
            errorLabel.topAnchor.constraint(equalTo: layoutMarginsGuide.topAnchor, constant: Self.toolTipHeight),
            errorLabel.bottomAnchor.constraint(equalTo: layoutMarginsGuide.bottomAnchor)
        ])
        errorLabel.embedSidesInMargins(in: self)
    }

    // MARK: Tooltip
    override func draw(_ rect: CGRect) {
        super.draw(rect)

        let actualRect = CGRect(x: bounds.minX, y: bounds.minY + Self.toolTipHeight, width: bounds.width, height: bounds.height - Self.toolTipHeight)
        let tooltipRect = CGRect(x: CustomTextField.padding.left, y: bounds.minY, width: Self.toolTipWidth, height: Self.toolTipHeight)
        let trianglePath = UIBezierPath()
        trianglePath.move(to: CGPoint(x: tooltipRect.minX, y: tooltipRect.maxY))
        trianglePath.addLine(to: CGPoint(x: tooltipRect.maxX, y: tooltipRect.maxY))
        trianglePath.addLine(to: CGPoint(x: tooltipRect.midX, y: tooltipRect.minY))
        trianglePath.addLine(to: CGPoint(x: tooltipRect.minX, y: tooltipRect.maxY))
        trianglePath.close()
        let actualRectPath = UIBezierPath(rect: actualRect)
        actualRectPath.append(trianglePath)
        let shape = CAShapeLayer()
        shape.path = actualRectPath.cgPath
        shape.fillColor = UIColor.compatibleLighterRedColor.cgColor
        self.layer.insertSublayer(shape, at: 0)
    }
}
