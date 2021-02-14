//
//  DateSelectionTableViewCell.swift
//  Notifire
//
//  Created by David Bielik on 13/02/2021.
//  Copyright © 2021 David Bielik. All rights reserved.
//

import UIKit

struct DateDisclosureCellModel {
    let selectedDateString: String
    let image: UIImage
}

// MARK: - DateDisclosureTableViewCell
class DateDisclosureTableViewCell: ReusableBaseTableViewCell, CellConfigurable {

    // MARK: - Properties
    // MARK: UI
    lazy var customImageView = UIImageView()
    lazy var customTextLabel = UILabel(style: .informationHeader)
    lazy var customDetailTextLabel = UILabel(style: .cellNotifirePositiveSubtitle)

    override func setup() {
        customTextLabel.text = "Show notifications from"

        customImageView.backgroundColor = .spinnerColor
        customImageView.layer.cornerRadius = 8
        customImageView.tintColor = .white
        customImageView.contentMode = .scaleAspectFit

        // Layout
        contentView.add(subview: customImageView)
        customImageView.heightAnchor.constraint(equalToConstant: Size.Image.settingsImage).isActive = true
        customImageView.widthAnchor.constraint(equalTo: customImageView.heightAnchor).isActive = true
        customImageView.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor).isActive = true
        customImageView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true

        // Container is used to center the labels properly
        let textContainer = UIView()
        contentView.add(subview: textContainer)
        textContainer.leadingAnchor.constraint(equalTo: customImageView.trailingAnchor, constant: Size.standardMargin - 1).isActive = true
        textContainer.trailingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.trailingAnchor).isActive = true
        textContainer.centerYAnchor.constraint(equalTo: customImageView.centerYAnchor).isActive = true

        textContainer.add(subview: customTextLabel)
        customTextLabel.leadingAnchor.constraint(equalTo: textContainer.leadingAnchor).isActive = true
        customTextLabel.topAnchor.constraint(equalTo: textContainer.topAnchor).isActive = true

        textContainer.add(subview: customDetailTextLabel)
        customDetailTextLabel.leadingAnchor.constraint(equalTo: textContainer.leadingAnchor).isActive = true
        customDetailTextLabel.topAnchor.constraint(equalTo: customTextLabel.bottomAnchor, constant: 2).isActive = true
        customDetailTextLabel.bottomAnchor.constraint(equalTo: textContainer.bottomAnchor).isActive = true
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        let convertedFrame = customTextLabel.convert(customTextLabel.frame, to: self)
        separatorInset.left = convertedFrame.minX
    }

    // MARK: CellConfigurable
    typealias DataType = DateDisclosureCellModel

    func configure(data: DataType) {
        customDetailTextLabel.text = data.selectedDateString
        customImageView.image = data.image.withRenderingMode(.alwaysTemplate).withInset(UIEdgeInsets.init(everySide: Size.smallMargin))
    }
}
