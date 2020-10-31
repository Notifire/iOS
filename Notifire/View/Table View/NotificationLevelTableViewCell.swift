//
//  NotificationLevelTableViewCell.swift
//  Notifire
//
//  Created by David Bielik on 10/11/2018.
//  Copyright © 2018 David Bielik. All rights reserved.
//

import UIKit
import SkeletonView

class NotificationLevelTableViewCell: ReusableBaseTableViewCell {

    // MARK: - Properties
    static let reuseIdentifier = "NotificationLevelTableViewCell"

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

    let levelLabel: UILabel = {
        let label = UILabel(style: .informationHeader)
        label.isSkeletonable = true
        return label
    }()

    let levelSwitch: UISwitch = {
        let view = UISwitch()
        view.onTintColor = .primary
        view.isSkeletonable = true
        return view
    }()

    // MARK: - Inherited
    override func setup() {
        isSkeletonable = true
        layout()
        setupLevelSwitch()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        separatorInset.left = levelLabel.frame.minX
        levelSwitch.skeletonCornerRadius = Float(levelSwitch.bounds.height / 2)
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
