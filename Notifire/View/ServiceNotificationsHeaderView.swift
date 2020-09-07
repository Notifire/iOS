//
//  ServiceNotificationsHeaderView.swift
//  Notifire
//
//  Created by David Bielik on 09/11/2018.
//  Copyright © 2018 David Bielik. All rights reserved.
//

import UIKit

class CustomGradientLayer: CAGradientLayer {

    // MARK: - Lifecycle
    override init() {
        super.init()
        setup()
    }

    override init(layer: Any) {
        super.init(layer: layer)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    // MARK: - Private
    private func setup() {
        // gradient setup
        colors = [UIColor.black.withAlphaComponent(0.26).cgColor, UIColor.black.withAlphaComponent(0).cgColor]
        opacity = 0.65
    }
}

class GradientView: ConstrainableView {

    let gradientLayer = CustomGradientLayer()
    let opaqueBackgroundLayer = CALayer()
    let separator = HairlineView()

    override func setupSubviews() {
        backgroundColor = .clear
        separator.backgroundColor = .compatibleClearSeparator
        opaqueBackgroundLayer.backgroundColor = UIColor.compatibleBackgroundAccent.cgColor
        layer.addSublayer(opaqueBackgroundLayer)
        layer.addSublayer(gradientLayer)

        add(subview: separator)
        separator.embedSides(in: self)
        separator.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        let width = bounds.width
        let height = bounds.height
        opaqueBackgroundLayer.frame = CGRect(origin: .zero, size: CGSize(width: width, height: height/2))
        gradientLayer.frame = CGRect(origin: CGPoint(x: 0, y: height/2), size: CGSize(width: width, height: height/2))
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        guard
            #available(iOS 13.0, *),
            traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection)
        else { return }
        opaqueBackgroundLayer.backgroundColor = UIColor.compatibleBackgroundAccent.cgColor
        opaqueBackgroundLayer.setNeedsDisplay()
    }
}

class ServiceNotificationsHeaderView: ConstrainableView {

    // MARK: - Properties
    var floatingTopToTopConstraint: NSLayoutConstraint!
    var gradientVisible: Bool = false {
        didSet {
            guard oldValue != gradientVisible else { return }
            updateAppearance()
        }
    }

    // MARK: Views
    let gradientView = GradientView()
    let floatingContentView = UIView()

    let notificationsButton: NotifireButton = {
        let button = NotifireButton()
        button.setTitle("Notifications", for: .normal)
        return button
    }()

    // MARK: - Lifecycle
    override func setupSubviews() {
        layout()

        floatingContentView.layoutIfNeeded() // fix for the initial corner radius of notificationButton

        updateAppearance()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        notificationsButton.layer.cornerRadius = notificationsButton.bounds.height / 2
    }

    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        if clipsToBounds || isHidden || alpha == 0 {
            return nil
        }
        let pointInButton = notificationsButton.convert(point, from: self)
        if let result = notificationsButton.hitTest(pointInButton, with: event) {
            return result
        }
        return nil
    }

    // MARK: - Private
    private func layout() {
        heightAnchor.constraint(equalToConstant: Size.componentHeight).isActive = true

        add(subview: floatingContentView)
        floatingTopToTopConstraint = floatingContentView.topAnchor.constraint(equalTo: topAnchor)
        floatingTopToTopConstraint.isActive = true
        floatingContentView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        floatingContentView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        floatingContentView.heightAnchor.constraint(equalTo: heightAnchor).isActive = true

        floatingContentView.add(subview: gradientView)
        gradientView.embed(in: floatingContentView)

        floatingContentView.add(subview: notificationsButton)
        let centerY = notificationsButton.centerYAnchor.constraint(equalTo: floatingContentView.centerYAnchor)
        centerY.priority = UILayoutPriority(750)
        centerY.isActive = true
        notificationsButton.centerXAnchor.constraint(equalTo: floatingContentView.centerXAnchor).isActive = true
        notificationsButton.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.56).isActive = true
    }

    private func updateAppearance() {
        gradientView.isHidden = !gradientVisible
        backgroundColor = gradientVisible ? .clear : .compatibleBackgroundAccent
    }
}
