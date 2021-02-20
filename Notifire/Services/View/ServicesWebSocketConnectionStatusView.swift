//
//  ServicesWebSocketConnectionStatusView.swift
//  Notifire
//
//  Created by David Bielik on 03/10/2020.
//  Copyright © 2020 David Bielik. All rights reserved.
//

import UIKit

class ServicesWebSocketConnectionStatusView: ConstrainableView {

    // MARK: - Properties
    // MARK: Views
    lazy var statusView: UIView = {
        let view = UIView()
        view.isUserInteractionEnabled = false
        view.clipsToBounds = true
        return view
    }()

    lazy var statusShadowView: UIView = {
        let view = UIView()
        view.isUserInteractionEnabled = false
        return view
    }()

    lazy var gradientLayer: CustomGradientLayer = {
        let gradient = CustomGradientLayer()
        gradient.gradientDirection = .fromBottom
        gradient.gradientStyle = .normal
        return gradient
    }()

    lazy var connectingIndicatorView: UIActivityIndicatorView = {
        let indicator: UIActivityIndicatorView
        if #available(iOS 13.0, *) {
            indicator = UIActivityIndicatorView(style: .medium)
        } else {
            indicator = UIActivityIndicatorView(style: .white)
        }
        indicator.color = .white
        indicator.hidesWhenStopped = true
        indicator.startAnimating()
        indicator.alpha = 0
        return indicator
    }()

    var connectingIndicatorTrailingConstraint: NSLayoutConstraint?
    var connectingIndicatorWidthConstraint: NSLayoutConstraint?

    var showsConnectingIndicator: Bool = false {
        didSet {
            connectingIndicatorTrailingConstraint?.constant = showsConnectingIndicator ? -Size.smallMargin : 0
            connectingIndicatorWidthConstraint?.isActive = !showsConnectingIndicator
        }
    }

    var currentLabel: UILabel?

    // MARK: - Inherited
    override var intrinsicContentSize: CGSize {
        return CGSize(width: UIView.noIntrinsicMetric, height: Size.footerHeight)
    }

    override open func setupSubviews() {
        super.setupSubviews()
        isUserInteractionEnabled = false
        setShadowViewShadow()

        // Gradient
        layer.insertSublayer(gradientLayer, at: 0)

        // Status shadow
        add(subview: statusShadowView)
        statusShadowView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        statusShadowView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        statusShadowView.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 0.5).isActive = true
        let statusShadowViewWidthConstraint = statusShadowView.widthAnchor.constraint(equalToConstant: Size.doubleMargin)
        statusShadowViewWidthConstraint.priority = UILayoutPriority(rawValue: 749)
        statusShadowViewWidthConstraint.isActive = true

        statusShadowView.add(subview: statusView)
        statusView.embed(in: statusShadowView)

        // Indicator view
        statusView.add(subview: connectingIndicatorView)
        connectingIndicatorView.centerYAnchor.constraint(equalTo: statusView.centerYAnchor).isActive = true
        let indicatorTrailingConstraint = connectingIndicatorView.trailingAnchor.constraint(equalTo: statusView.trailingAnchor)
        indicatorTrailingConstraint.isActive = true
        connectingIndicatorTrailingConstraint = indicatorTrailingConstraint

        let indicatorWidthConstraint = connectingIndicatorView.widthAnchor.constraint(equalToConstant: 0)
        indicatorWidthConstraint.isActive = true
        connectingIndicatorWidthConstraint = indicatorWidthConstraint
    }

    private func addLabel() -> UILabel {
        let label = UILabel(style: .connectionStatus)
        label.alpha = 0

        statusView.add(subview: label)
        label.centerYAnchor.constraint(equalTo: statusView.centerYAnchor).isActive = true
        if let oldLabel = currentLabel {
            let temporaryLeadingConstraint = label.leadingAnchor.constraint(equalTo: oldLabel.leadingAnchor)
            temporaryLeadingConstraint.priority = UILayoutPriority(rawValue: 749)
            temporaryLeadingConstraint.isActive = true
        }
        layoutIfNeeded()
        label.leadingAnchor.constraint(equalTo: statusView.layoutMarginsGuide.leadingAnchor).isActive = true
        label.trailingAnchor.constraint(equalTo: connectingIndicatorView.leadingAnchor, constant: -Size.smallMargin).isActive = true

        return label
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        // Round the corners
        statusView.layer.cornerRadius = statusView.bounds.height / 2
        statusShadowView.layer.cornerRadius = statusView.bounds.height / 2

        // Gradient frame
        gradientLayer.setFrameWithoutAnimation(bounds)
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        guard
            #available(iOS 13.0, *),
            traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection)
        else { return }
        setShadowViewShadow()
        gradientLayer.setup()
        gradientLayer.setNeedsDisplay()
    }

    // MARK: - Private
    private func setShadowViewShadow() {
        guard
            #available(iOS 13.0, *),
            traitCollection.userInterfaceStyle == .dark
        else {
            statusShadowView.layer.shadowRadius = 2
            statusShadowView.layer.shadowColor = UIColor.compatibleShadow.cgColor
            statusShadowView.layer.shadowOpacity = 0.6
            statusShadowView.layer.shadowOffset = CGSize(width: 0, height: 1)
            return
        }
        statusShadowView.layer.shadowRadius = 3
        statusShadowView.layer.shadowColor = UIColor.compatibleShadow.cgColor
        statusShadowView.layer.shadowOpacity = 1
        statusShadowView.layer.shadowOffset = CGSize(width: 0, height: 1)
    }

    // MARK: - Methods
    func updateStyle(from connectionStatus: WebSocketConnectionViewModel.ViewState) {
        let duration: TimeInterval = 0.4
        let maybeOldLabel = currentLabel
        let newLabel = addLabel()

        // Update titles
        // Prepare indicator view if needed
        switch connectionStatus {
        case .offline:
            showsConnectingIndicator = false
            newLabel.text = "Offline mode"
        case .connecting:
            showsConnectingIndicator = true
            newLabel.text = "Connecting"
        case .connected:
            showsConnectingIndicator = false
            newLabel.text = "Connected"
        }

        // Set new label to current label
        currentLabel = newLabel

        // Make sure the old label doesn't jump
        if let old = maybeOldLabel {
            old.removeConstraints(old.constraints)

            old.leadingAnchor.constraint(equalTo: newLabel.leadingAnchor).isActive = true
            old.centerYAnchor.constraint(equalTo: newLabel.centerYAnchor).isActive = true

            old.layoutIfNeeded()
        }

        UIView.animateKeyframes(withDuration: duration, delay: 0, options: [], animations: {
            UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 0.6) {
                // Title alpha
                maybeOldLabel?.alpha = 0
                if !self.showsConnectingIndicator {
                    // hide indicator
                    self.connectingIndicatorView.alpha = 0
                }
            }
            UIView.addKeyframe(withRelativeStartTime: 0.35, relativeDuration: 0.65) {
                newLabel.alpha = 1
                if self.showsConnectingIndicator {
                    // show indicator
                    self.connectingIndicatorView.alpha = 1
                }
            }
            UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 0.8) {
                // Background color
                switch connectionStatus {
                case .offline:
                    self.statusView.backgroundColor = .compatibleGray
                case .connecting:
                    self.statusView.backgroundColor = .compatibleGray
                case .connected:
                    self.statusView.backgroundColor = .compatibleGreen
                }

                // Layout statusview with new title
                self.layoutIfNeeded()
            }
        }, completion: { _ in
            maybeOldLabel?.removeFromSuperview()
        })
    }

    func showStatusViewAnimated(completion: ((Bool) -> Void)? = nil) {
        alpha = 0
        statusShadowView.transform = CGAffineTransform.identity.translatedBy(x: 0, y: Size.componentHeight)
        UIView.animateKeyframes(withDuration: 0.3, delay: 0, options: [], animations: {
            UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 0.8) {
                self.alpha = 1
            }
            UIView.addKeyframe(withRelativeStartTime: 0.3, relativeDuration: 0.7) {
                self.statusShadowView.transform = .identity
            }
        }, completion: { finished in
            completion?(finished)
        })
    }

    func hideStatusViewAnimated(completion: ((Bool) -> Void)? = nil) {
        UIView.animateKeyframes(withDuration: 0.3, delay: 0, options: [], animations: {
            UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 1) {
                self.statusShadowView.transform = CGAffineTransform.identity.translatedBy(x: 0, y: self.bounds.height)
            }
            UIView.addKeyframe(withRelativeStartTime: 0.3, relativeDuration: 0.7) {
                self.alpha = 0
            }
        }, completion: { finished in
            completion?(finished)
        })
    }
}
