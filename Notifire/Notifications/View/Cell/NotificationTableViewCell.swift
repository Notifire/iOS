//
//  NotificationTableViewCell.swift
//  Notifire
//
//  Created by David Bielik on 05/12/2018.
//  Copyright © 2018 David Bielik. All rights reserved.
//

import UIKit

protocol NotificationPresenting: class {
    /// The object that is currently used as the ReadUnreadView (`CircleView`)
    var isNotificationReadView: UIView? { get set }
    /// The Y axis anchor that this view will be centerY constrained to.
    var centerYAnchorForNotificationReadView: NSLayoutYAxisAnchor { get }

    /// Adds / removes the `isNotificationReadView` from the cell's contentView
    func updateNotificationReadView(from notification: LocalNotifireNotification)
}

extension NotificationPresenting where Self: BaseTableViewCell {
    func updateNotificationReadView(from notification: LocalNotifireNotification) {
        if notification.isRead {
            isNotificationReadView?.removeFromSuperview()
            isNotificationReadView = nil
        } else {
            guard isNotificationReadView == nil else { return }
            let circleView = CircleView()
            circleView.backgroundColor = .primary
            contentView.add(subview: circleView)
            circleView.heightAnchor.constraint(equalTo: circleView.widthAnchor).isActive = true
            circleView.widthAnchor.constraint(equalToConstant: Size.Image.unreadNotificationAlert).isActive = true
            circleView.centerYAnchor.constraint(equalTo: centerYAnchorForNotificationReadView).isActive = true
            let leadingSpace = (contentView.layoutMargins.left - Size.Image.unreadNotificationAlert) / 2
            circleView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: leadingSpace).isActive = true
            isNotificationReadView = circleView
        }
    }
}

class NotificationBaseTableViewCell: BaseTableViewCell, NotificationPresenting, CellConfigurable {

    typealias DataType = LocalNotifireNotification

    // MARK: - Properties
    var currentNotificationID: String?
    // MARK: UI
    let indicatorStack = IndicatorStackView()

    var isNotificationReadView: UIView?
    var centerYAnchorForNotificationReadView: NSLayoutYAxisAnchor { return levelLabel.centerYAnchor }

    lazy var levelLabel: UILabel = {
        let label = UILabel(style: .emojiSmall)
        label.numberOfLines = 1
        label.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        label.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        return label
    }()

    lazy var bodyLabel: UILabel = {
        let label = UILabel(style: .cellInformation)
        label.numberOfLines = 6
        label.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        return label
    }()

    lazy var dateLabel: UILabel = {
        let label = UILabel(style: .cellSubtitle)
        label.numberOfLines = 1
        label.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        label.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        return label
    }()

    lazy var dateAndIndicatorContainer: UIView = UIView()

    // MARK: - Inherited
    override open func setup() {
        contentView.layoutMargins = UIEdgeInsets(top: Size.Cell.extendedSideMargin/2, left: Size.Cell.extendedSideMargin + Size.smallestMargin, bottom: Size.Cell.extendedSideMargin/2, right: 0)
        accessoryType = .disclosureIndicator
        backgroundColor = .compatibleSystemBackground
        layout()
    }

    // MARK: - Private
    func layout() {
        // Almost .required priority Cell Height to guarantee at least `Size.Cell.heightExtended` in some cases
        contentView.heightAnchor.constraint(greaterThanOrEqualToConstant: Size.Cell.heightExtended).with(priority: .init(999)).isActive = true

        contentView.add(subview: dateAndIndicatorContainer)
        dateAndIndicatorContainer.add(subview: dateLabel)
        dateAndIndicatorContainer.add(subview: indicatorStack)

        dateLabel.topAnchor.constraint(equalTo: dateAndIndicatorContainer.topAnchor).isActive = true
        dateLabel.trailingAnchor.constraint(equalTo: dateAndIndicatorContainer.trailingAnchor).isActive = true

        indicatorStack.topAnchor.constraint(equalTo: dateLabel.bottomAnchor, constant: Size.smallestMargin).isActive = true
        indicatorStack.bottomAnchor.constraint(equalTo: dateAndIndicatorContainer.bottomAnchor).isActive = true
        indicatorStack.trailingAnchor.constraint(equalTo: dateAndIndicatorContainer.trailingAnchor).isActive = true

        dateAndIndicatorContainer.trailingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.trailingAnchor).isActive = true
        dateAndIndicatorContainer.topAnchor.constraint(equalTo: contentView.layoutMarginsGuide.topAnchor).with(priority: .init(950)).isActive = true
        dateAndIndicatorContainer.bottomAnchor.constraint(lessThanOrEqualTo: contentView.layoutMarginsGuide.bottomAnchor).with(priority: .init(850)).isActive = true
        dateAndIndicatorContainer.widthAnchor.constraint(equalTo: dateLabel.widthAnchor).isActive = true

        contentView.add(subview: levelLabel)
        levelLabel.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor).isActive = true

        contentView.add(subview: bodyLabel)
        bodyLabel.leadingAnchor.constraint(equalTo: levelLabel.trailingAnchor, constant: Size.smallMargin).isActive = true
        bodyLabel.trailingAnchor.constraint(equalTo: dateAndIndicatorContainer.leadingAnchor, constant: -Size.smallMargin).isActive = true
        bodyLabel.bottomAnchor.constraint(lessThanOrEqualTo: contentView.layoutMarginsGuide.bottomAnchor).with(priority: .init(860)).isActive = true
        bodyLabel.bottomAnchor.constraint(greaterThanOrEqualTo: dateAndIndicatorContainer.bottomAnchor).isActive = true

        // Baseline
        levelLabel.firstBaselineAnchor.constraint(equalTo: bodyLabel.firstBaselineAnchor).with(priority: .init(900)).isActive = true
    }

    func configure(data: LocalNotifireNotification) {
        currentNotificationID = data.notificationID
    }
}

class NotificationTableViewCell: NotificationBaseTableViewCell {

    // MARK: - Properties
    override var centerYAnchorForNotificationReadView: NSLayoutYAxisAnchor { return serviceImageView.centerYAnchor }

    // MARK: Views
    lazy var serviceImageView = RoundedImageView()

    lazy var serviceNameLabel: UILabel = {
        let label = UILabel(style: .boldTinyCellTitle)
        label.numberOfLines = 1
        label.lineBreakMode = NSLineBreakMode.byTruncatingMiddle
        return label
    }()

    // MARK: - Inherited
    override func layout() {
        super.layout()

        contentView.add(subview: serviceNameLabel)
        serviceNameLabel.leadingAnchor.constraint(equalTo: bodyLabel.leadingAnchor).isActive = true
        serviceNameLabel.trailingAnchor.constraint(equalTo: bodyLabel.trailingAnchor).isActive = true
        serviceNameLabel.topAnchor.constraint(equalTo: contentView.layoutMarginsGuide.topAnchor).isActive = true

        contentView.add(subview: serviceImageView)
        serviceImageView.trailingAnchor.constraint(equalTo: levelLabel.trailingAnchor).isActive = true
        serviceImageView.heightAnchor.constraint(equalToConstant: Size.Image.tinyService).isActive = true
        serviceImageView.widthAnchor.constraint(equalTo: serviceImageView.heightAnchor).isActive = true
        serviceImageView.centerYAnchor.constraint(equalTo: serviceNameLabel.centerYAnchor).isActive = true

        bodyLabel.topAnchor.constraint(equalTo: serviceNameLabel.bottomAnchor, constant: Size.smallestMargin).isActive = true
        dateLabel.firstBaselineAnchor.constraint(equalTo: serviceNameLabel.firstBaselineAnchor).isActive = true
    }

    override func configure(data notification: LocalNotifireNotification) {
        super.configure(data: notification)
        guard let service: ServiceRepresentable = notification.service ?? notification.serviceSnippet else { return }
        // Local Service
        if let image = service.image {
            serviceImageView.sd_setImage(with: image.small, placeholderImage: LocalService.defaultImage, options: [], completed: nil)
        } else {
            serviceImageView.image = LocalService.defaultImage
        }
        serviceNameLabel.text = "\(service.name)"
        bodyLabel.text = notification.body
        let dateString = notification.date.formatRelativeString()
        dateLabel.text = dateString
        indicatorStack.set(textVisible: notification.text != nil, imageVisible: notification.additionalURL != nil)
        levelLabel.text = notification.level.emoji
        updateNotificationReadView(from: notification)
    }
}

class ServiceNotificationTableViewCell: NotificationBaseTableViewCell {

    // MARK: Views
    // MARK: - Inherited
    override func layout() {
        super.layout()

        bodyLabel.topAnchor.constraint(equalTo: contentView.layoutMarginsGuide.topAnchor).isActive = true
        dateLabel.firstBaselineAnchor.constraint(equalTo: bodyLabel.firstBaselineAnchor).isActive = true
    }

    override func configure(data notification: LocalNotifireNotification) {
        super.configure(data: notification)
        levelLabel.text = notification.level.emoji
        bodyLabel.text = notification.body
        let dateString = notification.date.formatRelativeString()
        dateLabel.text = dateString
        indicatorStack.set(textVisible: notification.text != nil, imageVisible: notification.additionalURL != nil)
        updateNotificationReadView(from: notification)
    }
}
