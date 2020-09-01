//
//  NotificationLevelTableViewCell.swift
//  Notifire
//
//  Created by David Bielik on 10/11/2018.
//  Copyright © 2018 David Bielik. All rights reserved.
//

import UIKit

class NotificationLevelTableViewCell: BaseTableViewCell {

    // MARK: - Properties
    static let identifier = "NotificationLevelTableViewCell"
    // MARK: Model
    var model: NotificationLevelModel! {
        didSet {
            updateUI()
        }
    }

    // MARK: Callback
    var onLevelChange: ((Bool) -> Void)?

    // MARK: Views
    let emojiLabel = UILabel(style: .emoji)

    let levelLabel = UILabel(style: .informationHeader)

    let levelSwitch: UISwitch = {
        let view = UISwitch()
        view.onTintColor = .notifireMainColor
        return view
    }()

    // MARK: - Inherited
    override func setup() {
        layout()
        setupLevelSwitch()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        separatorInset.left = levelLabel.frame.minX
    }

    // MARK: - Private
    private func layout() {
        contentView.add(subview: emojiLabel)
        emojiLabel.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor).isActive = true
        emojiLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
        emojiLabel.setContentHuggingPriority(.required, for: .horizontal)

        contentView.add(subview: levelLabel)
        levelLabel.leadingAnchor.constraint(equalTo: emojiLabel.trailingAnchor, constant: Size.Cell.extendedSideMargin).isActive = true
        levelLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true

        contentView.add(subview: levelSwitch)
        levelSwitch.trailingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.trailingAnchor).isActive = true
        levelSwitch.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
        levelLabel.trailingAnchor.constraint(equalTo: levelSwitch.leadingAnchor).isActive = true
    }

    private func setupLevelSwitch() {
        levelSwitch.addTarget(self, action: #selector(didChangeLevelSwitch), for: .valueChanged)
    }

    private func updateUI() {
        levelSwitch.setOn(model.enabled, animated: false)
        emojiLabel.text = model.level.emoji
        levelLabel.text = model.level.description
    }

    // MARK: Event Handler
    @objc private func didChangeLevelSwitch(levelSwitch: UISwitch) {
        onLevelChange?(levelSwitch.isOn)
    }
}
