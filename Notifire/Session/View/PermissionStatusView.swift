//
//  PermissionStatusView.swift
//  Notifire
//
//  Created by David Bielik on 22/11/2020.
//  Copyright © 2020 David Bielik. All rights reserved.
//

import UIKit

class PermissionStatusView: ConstrainableView {

    enum Status {
        /// Spinner
        case waiting
        /// Checkmark
        case allowed
        /// Exclamation
        case notAllowed

        var view: UIView {
            switch self {
            case .allowed:
                let imageView = UIImageView(image: #imageLiteral(resourceName: "checkmark").withRenderingMode(.alwaysTemplate))
                imageView.tintColor = .compatibleGreen
                return imageView
            case .waiting:
                return UIActivityIndicatorView.loadingIndicator
            case .notAllowed:
                let imageView = UIImageView(image: #imageLiteral(resourceName: "xmark").withRenderingMode(.alwaysTemplate))
                imageView.tintColor = .compatibleRed
                return imageView
            }
        }
    }

    enum StatusText {
        /// The text updates based on the status
        case statusDependent((Status) -> String)
        /// Use static text
        case `static`(String)
    }

    // MARK: - Properties
    /// Set this to get better behavior for text.
    var statusText: StatusText = .static("") { didSet { updateText() } }

    var text: String {
        switch statusText {
        case .static(let text):
            return text
        case .statusDependent(let stringGenerator):
            return stringGenerator(stateModel.state)
        }
    }

    let stateModel = StateModel(defaultValue: Status.waiting)

    // MARK: UI
    lazy var statusContainer = UIView()

    var currentStatusView: UIView?

    lazy var textLabel: UILabel = {
        let label = UILabel(style: .primary, text: text)
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.2
        label.numberOfLines = 1
        return label
    }()

    // MARK: - Inherited
    override func setupSubviews() {
        layout()

        stateModel.onStateChange = { [weak self] _, new in
            self?.updateAppearance(new)
        }

        updateAppearance(stateModel.state)
    }

    // MARK: - Public
    public func updateText() {
        textLabel.text = text
    }

    // MARK: - Private
    private func layout() {
        add(subview: statusContainer)
        statusContainer.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        statusContainer.heightAnchor.constraint(equalToConstant: Size.Image.symbol).isActive = true
        statusContainer.widthAnchor.constraint(equalTo: statusContainer.heightAnchor).isActive = true
        statusContainer.topAnchor.constraint(equalTo: topAnchor).isActive = true
        statusContainer.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true

        add(subview: textLabel)
        textLabel.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        textLabel.trailingAnchor.constraint(equalTo: statusContainer.leadingAnchor, constant: -Size.standardMargin).isActive = true
        textLabel.centerYAnchor.constraint(equalTo: statusContainer.centerYAnchor).isActive = true
    }

    private func updateAppearance(_ newStatus: Status) {
        let newStatusView = newStatus.view
        statusContainer.add(subview: newStatusView)
        newStatusView.embed(in: statusContainer)
        self.layoutIfNeeded()
        newStatusView.transform = CGAffineTransform.identity.scaledBy(x: 0.3, y: 0.3)
        newStatusView.alpha = 0

        let previousStatusView = currentStatusView
        currentStatusView = newStatusView
        UIView.animate(withDuration: 0.2, delay: 0, options: [.transitionFlipFromRight, .curveEaseOut], animations: {
            newStatusView.alpha = 1
            newStatusView.transform = .identity
            previousStatusView?.removeFromSuperview()
        }, completion: nil)
    }
}
