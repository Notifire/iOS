//
//  WarningView.swift
//  Notifire
//
//  Created by David Bielik on 22/11/2020.
//  Copyright © 2020 David Bielik. All rights reserved.
//

import UIKit

class WarningView: ConstrainableView {

    enum WarningStyle {
        case normal
        case important
    }

    // MARK: - Properties
    // MARK: Model
    public var warningStyle: WarningStyle = .normal { didSet { updateWarningStyleAppearance() } }

    var warningTitleText: String = "" { didSet { warningTitleLabel.text = warningTitleText } }

    var warningText: String = "" { didSet { warningTextLabel.text = warningText } }

    // MARK: UI
    lazy var warningImageView = UIImageView(image: #imageLiteral(resourceName: "exclamationmark.circle").withRenderingMode(.alwaysTemplate))

    lazy var warningTitleLabel = UILabel(style: .warningTitle, text: warningTitleText)

    lazy var warningTextLabel = UILabel(style: .secondary, text: warningText)

    /// View that shows a border and rounded corners.
    lazy var borderAndBackgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.warningBackgroundColor
        view.layer.borderWidth = 2
        view.layer.borderColor = UIColor.warningColor.cgColor
        view.layer.masksToBounds = true
        view.layer.cornerRadius = Theme.defaultCornerRadius * 2
        view.isUserInteractionEnabled = false
        return view
    }()

    // MARK: - Inherited
    override func setupSubviews() {
        // Shadow
        layer.shadowOffset = CGSize(width: 0, height: 2)
        layer.shadowRadius = 3
        layer.shadowOpacity = 0.4

        layoutMargins = UIEdgeInsets(everySide: Size.standardMargin)

        layout()
        updateWarningStyleAppearance()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        layer.shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: Theme.defaultCornerRadius * 2).cgPath
    }

    // MARK: - Private
    private func layout() {
        add(subview: borderAndBackgroundView)
        borderAndBackgroundView.embed(in: self)

        add(subview: warningImageView)
        warningImageView.widthAnchor.constraint(equalToConstant: Size.Image.symbol).isActive = true
        warningImageView.heightAnchor.constraint(equalTo: warningImageView.widthAnchor).isActive = true
        warningImageView.topAnchor.constraint(equalTo: layoutMarginsGuide.topAnchor).isActive = true
        warningImageView.leadingAnchor.constraint(equalTo: layoutMarginsGuide.leadingAnchor).isActive = true

        add(subview: warningTitleLabel)
        warningTitleLabel.centerYAnchor.constraint(equalTo: warningImageView.centerYAnchor).isActive = true
        warningTitleLabel.leadingAnchor.constraint(equalTo: warningImageView.trailingAnchor, constant: Size.smallMargin).isActive = true
        warningTitleLabel.trailingAnchor.constraint(equalTo: layoutMarginsGuide.trailingAnchor).isActive = true

        add(subview: warningTextLabel)
        warningTextLabel.topAnchor.constraint(equalTo: warningImageView.bottomAnchor, constant: Size.smallMargin).isActive = true
        warningTextLabel.bottomAnchor.constraint(equalTo: layoutMarginsGuide.bottomAnchor).isActive = true
        warningTextLabel.embedSidesInMargins(in: self)
    }

    private func updateWarningStyleAppearance() {
        switch warningStyle {
        case .normal:
            warningImageView.tintColor = .compatibleSecondaryLabel
            warningTitleLabel.textColor = .compatibleSecondaryLabel
            warningTextLabel.textColor = .compatibleSecondaryLabel
        case .important:
            warningImageView.tintColor = .compatibleRed
            warningTitleLabel.textColor = .compatibleRed
            warningTextLabel.textColor = .compatibleLabel
        }
    }
}
