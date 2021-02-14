//
//  SettingsCellConfigurations.swift
//  Notifire
//
//  Created by David Bielik on 14/11/2020.
//  Copyright © 2020 David Bielik. All rights reserved.
//

import UIKit

typealias SettingsDefaultCellConfiguration = CellConfiguration<UITableViewValue1Cell, DefaultCellAppearance>

typealias SettingsDisclosureCellConfiguration = DefaultDisclosureCellConfiguration

typealias SettingsCenteredCellConfiguration = CellConfiguration<UITableViewCenteredNegativeCell, DefaultTappableCellAppearance>

// MARK: - SettingsSwitchCellConfiguration
struct SettingsSwitchData {
    /// The keypath to the flag that is controlled by the `UISwitch`
    let sessionFlagKeypath: ReferenceWritableKeyPath<UserSessionSettings, Bool>
    /// This value is `true` if the session flag should be observed for changes via KVO.
    let shouldObserveFlag: Bool
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

    /// Holds the Observation so it doesn't get deallocated.
    /// For more info check `SettingsSwitchData.observeFlag`
    var flagObserver: NSKeyValueObservation?

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

    deinit {
        flagObserver?.invalidate()
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

        // Register the observer if needed
        if data.shouldObserveFlag {
            flagObserver?.invalidate()
            flagObserver = data.session?.settings.observe(data.sessionFlagKeypath, options: [.new, .old], changeHandler: { [weak self] (_, change) in
                guard
                    let `self` = self,
                    let newValue = change.newValue,
                    self.toggleSwitch.isOn != newValue
                else { return }
                // Update the switch and text if the new value is different
                self.toggleSwitch.isOn = newValue
                self.updateDescriptionText()
            })
        }
    }
}

typealias SettingsSwitchCellConfiguration = CellConfiguration<SettingsSwitchTableViewCell, DefaultAutomaticHeightCellAppearance>

// MARK: - SettingsActionCellConfiguration
typealias SettingsActionCellConfiguration = CellConfiguration<UITableViewActionCell, DisclosureCellAppearance>

// MARK: - SettingsWarningViewCellConfiguration
class UITableViewWarningCell: ReusableBaseTableViewCell, CellConfigurable {

    // MARK: - Properties
    // MARK: UI
    lazy var warningView: WarningView = {
        let view = WarningView()
        view.warningTitleText = "Enable notifications"
        view.warningText = "Notifications must be enabled for Notifire or the notifications your Services send won't be received on this device. Make sure to enable them in Settings."
        view.warningStyle = .important
        return view
    }()

    // MARK: - Inherited
    override func setup() {
        contentView.preservesSuperviewLayoutMargins = false
        contentView.layoutMargins = UIEdgeInsets(everySide: Size.standardMargin)

        layout()
    }

    // MARK: - Private
    private func layout() {
        contentView.add(subview: warningView)
        warningView.embedSidesInMargins(in: contentView)
        warningView.topAnchor.constraint(equalTo: contentView.layoutMarginsGuide.topAnchor).isActive = true
        warningView.bottomAnchor.constraint(equalTo: contentView.layoutMarginsGuide.bottomAnchor).isActive = true
    }

    // MARK: CellConfigurable
    typealias DataType = Any
    func configure(data: Any) {}
}

typealias SettingsWarningViewCellConfiguration = CellConfiguration<UITableViewWarningCell, DefaultCellAppearance>
