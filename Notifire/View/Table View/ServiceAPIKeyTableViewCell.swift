//
//  ServiceAPIKeyTableViewCell.swift
//  Notifire
//
//  Created by David Bielik on 10/11/2018.
//  Copyright © 2018 David Bielik. All rights reserved.
//

import UIKit

protocol ServiceAPIKeyCellDelegate: class {
    func shouldReloadServiceCell()
}

class ServiceAPIKeyTableViewCell: ReusableBaseTableViewCell {

    // MARK: - Properties
    static let reuseIdentifier = "ServiceAPIKeyTableViewCell"
    weak var delegate: ServiceAPIKeyCellDelegate?
    var serviceKey: String? {
        didSet {
            updateUI()
        }
    }

    // MARK: Views
    let keyTextField: CustomTextField = {
        let textField = CustomTextField()
        textField.isSecureTextEntry = true
        textField.isEnabled = false
        textField.font = UIFont.systemFont(ofSize: 16)
        return textField
    }()
    var keyTextFieldHeight: NSLayoutConstraint!

    let keyLabel = CopyableLabel(style: .secureInformation)

    lazy var visibilityButton: UIButton = {
        let button = UIButton()
        button.addTarget(self, action: #selector(didPressVisibilityButton), for: .touchUpInside)
        return button
    }()

    // MARK: - Inherited
    override func setup() {
        layout()
        updateUI()
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        keyTextField.skeletonCornerRadius = Float(keyTextField.layer.cornerRadius)
        updateUI()
    }

    // MARK: - Private
    private func layout() {
        contentView.add(subview: keyTextField)
        keyTextField.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor).isActive = true
        keyTextField.topAnchor.constraint(equalTo: contentView.topAnchor, constant: Size.Cell.extendedSideMargin).isActive = true
        let bottomConstraint = keyTextField.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -Size.Cell.extendedSideMargin)
        bottomConstraint.priority = UILayoutPriority(850)
        bottomConstraint.isActive = true

        contentView.add(subview: keyLabel)
        keyLabel.leadingAnchor.constraint(equalTo: keyTextField.layoutMarginsGuide.leadingAnchor).isActive = true
        keyLabel.trailingAnchor.constraint(equalTo: keyTextField.layoutMarginsGuide.trailingAnchor).isActive = true
        keyLabel.topAnchor.constraint(equalTo: keyTextField.layoutMarginsGuide.topAnchor).isActive = true
        keyLabel.bottomAnchor.constraint(equalTo: keyTextField.layoutMarginsGuide.bottomAnchor).isActive = true

        contentView.add(subview: visibilityButton)
        visibilityButton.leadingAnchor.constraint(equalTo: keyTextField.trailingAnchor, constant: Size.Cell.extendedSideMargin).isActive = true
        visibilityButton.trailingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.trailingAnchor).isActive = true
        visibilityButton.centerYAnchor.constraint(equalTo: keyLabel.firstBaselineAnchor).isActive = true
        visibilityButton.widthAnchor.constraint(equalTo: visibilityButton.heightAnchor).isActive = true
        visibilityButton.heightAnchor.constraint(equalToConstant: Size.iconSize).isActive = true
    }

    private func updateUI() {
        if let key = serviceKey {
            keyTextField.text = ""
            let paragraph = NSMutableParagraphStyle()
            paragraph.hyphenationFactor = 0
            let attributedString = NSAttributedString(string: key, attributes: [.paragraphStyle: paragraph])
            keyLabel.attributedText = attributedString
            keyLabel.isUserInteractionEnabled = true
            visibilityButton.setImage(#imageLiteral(resourceName: "visibility_on").withRenderingMode(.alwaysTemplate), for: .normal)
            visibilityButton.tintColor = .primary
        } else {
            if isSkeletonActive {
                keyTextField.text = ""
            } else {
                keyTextField.text = String(repeating: "*", count: 20)
            }
            keyLabel.text = ""
            keyLabel.isUserInteractionEnabled = false
            visibilityButton.setImage(#imageLiteral(resourceName: "visibility_off").withRenderingMode(.alwaysTemplate), for: .normal)
            visibilityButton.tintColor = .gray
        }
    }

    @objc private func didPressVisibilityButton() {
        self.delegate?.shouldReloadServiceCell()
    }
}
