//
//  SettingsTableViewCell.swift
//  Notifire
//
//  Created by David Bielik on 14/11/2020.
//  Copyright © 2020 David Bielik. All rights reserved.
//

import UIKit

// MARK: - SettingsDefaultCellConfiguration
typealias SettingsDefaultCellConfiguration = CellConfiguration<UITableViewValue1Cell, DefaultCellAppearance>

// MARK: - SettingsDisclosureCellConfiguration
typealias SettingsDisclosureCellConfiguration = CellConfiguration<UITableViewValue1Cell, DisclosureCellAppearance>

struct DisclosureCellAppearance: CellAppearanceDescribing {
    static var accessoryType: UITableViewCell.AccessoryType {
        return .disclosureIndicator
    }

    static var selectionStyle: UITableViewCell.SelectionStyle {
        return .default
    }
}

// MARK: - SettingsCenteredCellConfiguration
typealias SettingsCenteredCellConfiguration = CellConfiguration<UITableViewCenteredNegativeCell, DefaultTappableCellAppearance>

// MARK: - SettingsSwitchCellConfiguration
struct SettingsSwitchData {
    /// The keypath to the flag that is controlled by the `UISwitch`
    let sessionFlagKeypath: ReferenceWritableKeyPath<UserSessionSettings, Bool>
    /// The main text that is associated with this flag
    let text: String
    /// The description text displayed when the flag is switched on.
    let switchedOnDescriptionText: String
    /// The description text displayed when the flag is switched off.
    let switchedOffDescriptionText: String
    /// Current user session where the flag will be updated on switch toggle.
    weak var session: UserSession?
}

class SettingsSwitchTableViewCell: ReusableBaseTableViewCell, CellConfigurable {

    // MARK: - Properties
    var data: DataType?

    // MARK: UI
    lazy var toggleSwitch: UISwitch = {
        let view = UISwitch()
        view.onTintColor = .primary
        return view
    }()

    lazy var informationLabel = UILabel(style: .cellTitle)

    lazy var descriptionLabel = UILabel(style: .cellSubtitle)

    // MARK: Callback
    /// Called when the height of the cell should change
    var onCellHeightChange: (() -> Void)?

    // MARK: - Inherited
    override func setup() {
        let currentMargin = contentView.layoutMargins.left
        contentView.preservesSuperviewLayoutMargins = false
        contentView.layoutMargins = UIEdgeInsets(top: Size.smallestMargin, left: currentMargin, bottom: Size.standardMargin, right: currentMargin)

        // Add the switch
        toggleSwitch.addTarget(self, action: #selector(handleSwitchChange), for: .valueChanged)

        layout()
    }

    // MARK: - Private
    private func layout() {
        contentView.add(subview: toggleSwitch)
        toggleSwitch.topAnchor.constraint(equalTo: contentView.layoutMarginsGuide.topAnchor).isActive = true
        toggleSwitch.trailingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.trailingAnchor).isActive = true

        contentView.add(subview: informationLabel)
        informationLabel.centerYAnchor.constraint(equalTo: toggleSwitch.centerYAnchor).isActive = true
        informationLabel.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor).isActive = true
        informationLabel.trailingAnchor.constraint(equalTo: toggleSwitch.leadingAnchor, constant: Size.smallMargin).isActive = true

        contentView.add(subview: descriptionLabel)
        descriptionLabel.leadingAnchor.constraint(equalTo: informationLabel.leadingAnchor).isActive = true
        descriptionLabel.trailingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.trailingAnchor).isActive = true
        descriptionLabel.topAnchor.constraint(equalTo: toggleSwitch.bottomAnchor, constant: Size.smallMargin).isActive = true
        descriptionLabel.bottomAnchor.constraint(equalTo: contentView.layoutMarginsGuide.bottomAnchor).isActive = true
    }

    private func updateDescriptionText(animated: Bool = false) {
        guard let data = data else { return }
        let changeBlock = { [weak self] in
            guard let `self` = self else { return }
            self.descriptionLabel.text = self.toggleSwitch.isOn ? data.switchedOnDescriptionText : data.switchedOffDescriptionText
        }
        if animated {
            UIView.transition(with: descriptionLabel, duration: 0.2, options: [.transitionCrossDissolve], animations: {
                changeBlock()
            }, completion: nil)
            layoutIfNeeded()
            onCellHeightChange?()
        } else {
            changeBlock()
        }
    }

    // MARK: Event Handling
    @objc private func handleSwitchChange(switch: UISwitch) {
        guard let keyPath = data?.sessionFlagKeypath else { return }
        data?.session?.settings[keyPath: keyPath] = toggleSwitch.isOn
        updateDescriptionText(animated: true)
    }

    // MARK: - CellConfigurable
    typealias DataType = SettingsSwitchData

    func configure(data: SettingsSwitchData) {
        // Save data for later
        self.data = data
        // Update
        informationLabel.text = data.text
        toggleSwitch.isOn = data.session?.settings[keyPath: data.sessionFlagKeypath] ?? false
        updateDescriptionText()
    }
}

typealias SettingsSwitchCellConfiguration = CellConfiguration<SettingsSwitchTableViewCell, DefaultAutomaticHeightCellAppearance>
