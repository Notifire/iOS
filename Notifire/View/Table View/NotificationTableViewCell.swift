//
//  NotificationTableViewCell.swift
//  Notifire
//
//  Created by David Bielik on 05/12/2018.
//  Copyright © 2018 David Bielik. All rights reserved.
//

import UIKit

protocol NotificationPresenting: class {
    var isNotificationReadView: UIView? { get set }
    func updateNotificationReadView(from notification: LocalNotifireNotification)
}

extension NotificationPresenting where Self: BaseTableViewCell {
    func updateNotificationReadView(from notification: LocalNotifireNotification) {
        if notification.isRead {
            isNotificationReadView?.removeFromSuperview()
            isNotificationReadView = nil
        } else {
            guard isNotificationReadView == nil else { return }
            let circleView = UIView()
            circleView.backgroundColor = .notifireMainColor
            contentView.add(subview: circleView)
            circleView.heightAnchor.constraint(equalTo: circleView.widthAnchor).isActive = true
            circleView.widthAnchor.constraint(equalToConstant: Size.Image.unreadNotificationAlert).isActive = true
            circleView.topAnchor.constraint(equalTo: contentView.layoutMarginsGuide.topAnchor).isActive = true
            let leadingSpace = (contentView.layoutMargins.left - Size.Image.unreadNotificationAlert) / 2
            circleView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: leadingSpace).isActive = true
            isNotificationReadView = circleView
            circleView.layer.cornerRadius = Size.Image.unreadNotificationAlert / 2
        }
    }
}

class NotificationBaseTableViewCell: BaseTableViewCell, NotificationPresenting {

    let indicatorStack = IndicatorStackView()

    var isNotificationReadView: UIView?

    let bodyLabel: UILabel = {
        let label = UILabel(style: .cellSubtitle)
        label.numberOfLines = 1
        return label
    }()

    let dateLabel: UILabel = {
        let label = UILabel(style: .cellSubtitle)
        label.numberOfLines = 1
        label.setContentHuggingPriority(UILayoutPriority.defaultHigh, for: .horizontal)
        label.setContentCompressionResistancePriority(UILayoutPriority(rawValue: 999), for: .horizontal)
        return label
    }()

    // MARK: - Inherited
    override open func setup() {
        contentView.layoutMargins = UIEdgeInsets(top: Size.Cell.extendedSideMargin/2, left: Size.Cell.extendedSideMargin, bottom: Size.Cell.extendedSideMargin/2, right: 0)
        accessoryType = .disclosureIndicator
        backgroundColor = .backgroundColor
        layout()
    }

    func viewAboveIndicatorStack() -> UIView {
        return UIView()
    }

    // MARK: - Private
    func layout() {
        let viewAboveStack = viewAboveIndicatorStack()
        contentView.add(subview: viewAboveStack)
        viewAboveStack.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor).isActive = true
        viewAboveStack.topAnchor.constraint(equalTo: contentView.layoutMarginsGuide.topAnchor).isActive = true
        let bottomConstraint = viewAboveStack.bottomAnchor.constraint(lessThanOrEqualTo: contentView.layoutMarginsGuide.bottomAnchor)
        bottomConstraint.priority = UILayoutPriority(999)
        bottomConstraint.isActive = true
        viewAboveStack.widthAnchor.constraint(equalTo: viewAboveStack.heightAnchor).isActive = true
        viewAboveStack.heightAnchor.constraint(equalToConstant: Size.Image.smallService).isActive = true

        let stackContainerView = UIView()
        contentView.add(subview: stackContainerView)
        stackContainerView.topAnchor.constraint(equalTo: viewAboveStack.bottomAnchor, constant: Size.Cell.extendedSideMargin/2).isActive = true
        let stackBottomConstraint = stackContainerView.bottomAnchor.constraint(equalTo: contentView.layoutMarginsGuide.bottomAnchor)
        stackBottomConstraint.priority = UILayoutPriority(rawValue: 999)
        stackBottomConstraint.isActive = true
        stackContainerView.leadingAnchor.constraint(equalTo: viewAboveStack.leadingAnchor).isActive = true
        stackContainerView.trailingAnchor.constraint(equalTo: viewAboveStack.trailingAnchor).isActive = true

        stackContainerView.add(subview: indicatorStack)
        indicatorStack.centerXAnchor.constraint(equalTo: stackContainerView.centerXAnchor).isActive = true
        indicatorStack.centerYAnchor.constraint(equalTo: stackContainerView.centerYAnchor).isActive = true
        indicatorStack.heightAnchor.constraint(equalToConstant: Size.Image.indicator).isActive = true
    }
}

class NotificationTableViewCell: NotificationBaseTableViewCell, CellConfigurable {
    typealias DataType = LocalNotifireNotification

    // MARK: - Properties
    // MARK: Views
    let serviceImageView = RoundedEmojiImageView(image: nil, size: .normal)

    let serviceInformationLabel: UILabel = {
        let label = UILabel(style: .semiboldCellTitle)
        label.numberOfLines = 1
        label.lineBreakMode = NSLineBreakMode.byTruncatingMiddle
        return label
    }()

    override func viewAboveIndicatorStack() -> UIView {
        return serviceImageView
    }

    // MARK: - Inherited
    override func layout() {
        super.layout()
        let serviceAndDateStack = UIStackView(arrangedSubviews: [serviceInformationLabel, dateLabel])
        serviceAndDateStack.axis = .horizontal
        serviceAndDateStack.distribution = .fill
        serviceAndDateStack.alignment = .center

        let labelStack = UIStackView(arrangedSubviews: [serviceAndDateStack, bodyLabel])
        labelStack.axis = .vertical
        labelStack.distribution = .fill
        labelStack.alignment = .leading
        labelStack.setCustomSpacing(Size.Cell.extendedSideMargin/4, after: serviceAndDateStack)

        contentView.add(subview: labelStack)
        labelStack.leadingAnchor.constraint(equalTo: serviceImageView.trailingAnchor, constant: Size.Cell.extendedSideMargin/2).isActive = true
        labelStack.topAnchor.constraint(equalTo: contentView.layoutMarginsGuide.topAnchor).isActive = true
        labelStack.bottomAnchor.constraint(equalTo: contentView.layoutMarginsGuide.bottomAnchor).isActive = true
        labelStack.trailingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.trailingAnchor).isActive = true

        serviceAndDateStack.widthAnchor.constraint(equalTo: labelStack.widthAnchor).isActive = true
    }

    func configure(data notification: LocalNotifireNotification) {
        guard let service = notification.service.first else { return }
        serviceImageView.image = service.image
        serviceInformationLabel.text = "\(service.name)"
        bodyLabel.text = notification.body
        let dateString = notification.date.formatRelativeString()
        dateLabel.text = dateString
        indicatorStack.set(textVisible: notification.text != nil, imageVisible: notification.additionalURL != nil)
        serviceImageView.set(level: notification.level)
        updateNotificationReadView(from: notification)
    }
}

class ServiceNotificationTableViewCell: NotificationBaseTableViewCell, CellConfigurable {
    typealias DataType = LocalNotifireNotification

    // MARK: Views
    let levelLabel = UILabel(style: .emoji)

    override func viewAboveIndicatorStack() -> UIView {
        return levelLabel
    }

    // MARK: - Inherited
    override func setup() {
        super.setup()

        bodyLabel.set(style: .cellInformation)
        bodyLabel.numberOfLines = 3
    }

    override func layout() {
        super.layout()

        contentView.add(subview: dateLabel)
        dateLabel.topAnchor.constraint(equalTo: contentView.layoutMarginsGuide.topAnchor).isActive = true
        dateLabel.trailingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.trailingAnchor).isActive = true

        contentView.add(subview: bodyLabel)
        bodyLabel.leadingAnchor.constraint(equalTo: levelLabel.trailingAnchor, constant: Size.Cell.extendedSideMargin/2).isActive = true
        bodyLabel.trailingAnchor.constraint(equalTo: dateLabel.leadingAnchor, constant: -Size.Cell.extendedSideMargin/2).isActive = true
        bodyLabel.topAnchor.constraint(equalTo: contentView.layoutMarginsGuide.topAnchor).isActive = true
        bodyLabel.bottomAnchor.constraint(equalTo: contentView.layoutMarginsGuide.bottomAnchor).isActive = true
    }

    func configure(data notification: LocalNotifireNotification) {
        levelLabel.text = notification.level.emoji
        bodyLabel.text = notification.body
        let dateString = notification.date.formatRelativeString()
        dateLabel.text = dateString
        indicatorStack.set(textVisible: notification.text != nil, imageVisible: notification.additionalURL != nil)
        updateNotificationReadView(from: notification)
    }
}
