//
//  GenericUITableViewCells.swift
//  Notifire
//
//  Created by David Bielik on 15/11/2020.
//  Copyright © 2020 David Bielik. All rights reserved.
//

import UIKit

// MARK: - UITableViewReusableCell
/// A `UITableViewCell` that conforms to the `Reusable & CellConfigurable` protocol.
class UITableViewReusableCell: ReusableBaseTableViewCell, CellConfigurable {
    // MARK: - Properties
    // MARK: CellConfigurable
    typealias DataType = String

    func configure(data: DataType) {
        textLabel?.text = data
    }
}

// MARK: - UITableViewCenteredNegativeCell
class UITableViewCenteredNegativeCell: UITableViewReusableCell {
    override func setup() {
        textLabel?.set(style: .negativeMedium)
    }
}

// MARK: - UITableViewCenteredNegativeCell
class UITableViewCenteredPositiveCell: UITableViewReusableCell {
    override func setup() {
        textLabel?.set(style: .notifirePositive)
        textLabel?.textAlignment = .center
    }
}

// MARK: - UITableViewActionCell
class UITableViewActionCell: UITableViewReusableCell {
    override func setup() {
        textLabel?.set(style: .notifirePositive)
    }
}

// MARK: - UITableViewValue1Cell
/// A `UITableViewCell` with style `.value1` that conforms to the `Reusable & CellConfigurable` protocol.
class UITableViewValue1Cell: ReusableBaseTableViewCell, CellConfigurable {

    // MARK: - Initialization
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .value1, reuseIdentifier: reuseIdentifier)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    // MARK: CellConfigurable
    typealias DataType = (text: String, detailText: String?)

    func configure(data: DataType) {
        textLabel?.text = data.text
        detailTextLabel?.text = data.detailText
    }
}

// MARK: - UITableViewImageTextCell
class UITableViewImageTextCell: ReusableBaseTableViewCell, CellConfigurable {

    // MARK: - Properties
    // MARK: UI
    lazy var customImageView = UIImageView()
    lazy var customTextLabel = UILabel(style: .informationHeader)

    override func setup() {
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

        contentView.add(subview: customTextLabel)
        customTextLabel.leadingAnchor.constraint(equalTo: customImageView.trailingAnchor, constant: Size.standardMargin - 1).isActive = true
        customTextLabel.centerYAnchor.constraint(equalTo: customImageView.centerYAnchor).isActive = true
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        separatorInset.left = customTextLabel.frame.minX
    }

    // MARK: CellConfigurable
    typealias DataType = (text: String, image: UIImage)

    func configure(data: DataType) {
        customTextLabel.text = data.text
        customImageView.image = data.image.withRenderingMode(.alwaysTemplate).withInset(UIEdgeInsets.init(everySide: Size.smallMargin))
    }
}

/// https://stackoverflow.com/a/63608625/4249857
extension UIImage {

    func withInset(_ insets: UIEdgeInsets) -> UIImage? {
        let cgSize = CGSize(width: self.size.width + insets.left * self.scale + insets.right * self.scale,
                            height: self.size.height + insets.top * self.scale + insets.bottom * self.scale)

        UIGraphicsBeginImageContextWithOptions(cgSize, false, self.scale)
        defer { UIGraphicsEndImageContext() }

        let origin = CGPoint(x: insets.left * self.scale, y: insets.top * self.scale)
        self.draw(at: origin)

        return UIGraphicsGetImageFromCurrentImageContext()?.withRenderingMode(self.renderingMode)
    }
}

class UITableViewLevelCell: ReusableBaseTableViewCell, CellConfigurable {

    // MARK: UI
    lazy var emojiLabel = UILabel(style: .emoji)
    lazy var customTextLabel = UILabel(style: .informationHeader)

    // MARK: CellConfigurable
    typealias DataType = NotificationLevel

    override func setup() {
        contentView.add(subview: emojiLabel)
        emojiLabel.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor).isActive = true
        emojiLabel.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true

        contentView.add(subview: customTextLabel)
        customTextLabel.leadingAnchor.constraint(equalTo: emojiLabel.trailingAnchor, constant: Size.standardMargin - 1).isActive = true
        customTextLabel.centerYAnchor.constraint(equalTo: emojiLabel.centerYAnchor).isActive = true
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        separatorInset.left = customTextLabel.frame.minX
    }

    func configure(data: NotificationLevel) {
        customTextLabel.text = data.description
        emojiLabel.text = data.emoji
    }
}
