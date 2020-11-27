//
//  NotificationDetailCells.swift
//  Notifire
//
//  Created by David Bielik on 11/12/2018.
//  Copyright © 2018 David Bielik. All rights reserved.
//

import UIKit
import RealmSwift

struct NotificationDetailHeader {
    let serviceName: String
    let serviceImage: UIImage
    let notificationDate: Date
    let notificationLevel: NotificationLevel
}

class NotificationDetailHeaderCell: BaseTableViewCell, CellConfigurable {

    typealias DataType = NotificationDetailHeader

    // MARK: - Properties
    // MARK: Views
    let serviceImageView = RoundedEmojiImageView(image: nil)
    let serviceNameLabel: UILabel = {
        let label = UILabel(style: .title)
        label.numberOfLines = 0
        return label
    }()

    override func setup() {
        layout()
    }

    func configure(data: DataType) {
        serviceImageView.image = data.serviceImage
        serviceNameLabel.text = data.serviceName
        serviceImageView.set(level: data.notificationLevel)
    }

    private func layout() {
        contentView.add(subview: serviceImageView)
        serviceImageView.topAnchor.constraint(equalTo: contentView.layoutMarginsGuide.topAnchor).isActive = true
        let bottomConstraint = serviceImageView.bottomAnchor.constraint(equalTo: contentView.layoutMarginsGuide.bottomAnchor)
        bottomConstraint.priority = UILayoutPriority(999)
        bottomConstraint.isActive = true
        serviceImageView.trailingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.trailingAnchor).isActive = true
        serviceImageView.heightAnchor.constraint(equalTo: serviceImageView.widthAnchor).isActive = true
        serviceImageView.widthAnchor.constraint(equalToConstant: Size.Image.normalService).isActive = true

        contentView.add(subview: serviceNameLabel)
        serviceNameLabel.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor).isActive = true
        serviceNameLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
        serviceNameLabel.trailingAnchor.constraint(equalTo: serviceImageView.leadingAnchor).isActive = true
    }
}

struct NotificationDetailTitleBody {
    let body: String?
}

class NotificationDetailTitleBodyCell: BaseTableViewCell, CellConfigurable {
    typealias DataType = NotificationDetailTitleBody

    // MARK: - Properties
    // MARK: Views
    let notificationBodyLabel = CopyableLabel(style: .informationHeader)

    override func setup() {
        layout()
    }

    func configure(data: DataType) {
        notificationBodyLabel.text = data.body
    }

    private func layout() {
        contentView.add(subview: notificationBodyLabel)
        notificationBodyLabel.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor).isActive = true
        notificationBodyLabel.topAnchor.constraint(equalTo: contentView.layoutMarginsGuide.topAnchor).isActive = true
        notificationBodyLabel.bottomAnchor.constraint(equalTo: contentView.layoutMarginsGuide.bottomAnchor).isActive = true
        notificationBodyLabel.trailingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.trailingAnchor).isActive = true
    }
}

protocol NotificationDetailOptionallyDisplaying {
    static var indicatorImage: UIImage { get }
}

extension NotificationDetailOptionallyDisplaying where Self: BaseTableViewCell {
    func addIndicatorImageView() {
        let indicatorImageView = UIImageView(notifireImage: type(of: self).indicatorImage)
        let imageWidth = Size.Image.indicator
        let distanceFromContentLeadingAnchor = (Size.Cell.wideSideMargin - imageWidth) / 2
        contentView.add(subview: indicatorImageView)
        indicatorImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: distanceFromContentLeadingAnchor).isActive = true
        indicatorImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
        indicatorImageView.heightAnchor.constraint(equalTo: indicatorImageView.widthAnchor).isActive = true
        indicatorImageView.widthAnchor.constraint(equalToConstant: imageWidth).isActive = true
    }
}

class NotificationDetailAdditionalTextCell: BaseTableViewCell, CellConfigurable, NotificationDetailOptionallyDisplaying {
    typealias DataType = String

    // MARK: - Properties
    // MARK: NotificationDetailIndicatorCell
    static var indicatorImage: UIImage {
        return #imageLiteral(resourceName: "notification_indicator_additional_text")
    }
    // MARK: Views
    let additionalTextLabel = CopyableLabel(style: .informationHeader)

    override func setup() {
        layout()
    }

    func configure(data: DataType) {
        additionalTextLabel.text = data
    }

    private func layout() {
        contentView.add(subview: additionalTextLabel)
        additionalTextLabel.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor).isActive = true
        additionalTextLabel.topAnchor.constraint(equalTo: contentView.layoutMarginsGuide.topAnchor).isActive = true
        additionalTextLabel.bottomAnchor.constraint(equalTo: contentView.layoutMarginsGuide.bottomAnchor).isActive = true
        additionalTextLabel.trailingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.trailingAnchor).isActive = true

        addIndicatorImageView()
    }
}

class NotificationDetailURLCell: BaseTableViewCell, CellConfigurable, NotificationDetailOptionallyDisplaying {
    typealias DataType = URL

    // MARK: - Properties
    var url: DataType?
    // MARK: NotificationDetailIndicatorCell
    static var indicatorImage: UIImage {
        return #imageLiteral(resourceName: "baseline_link_black_48pt")
    }
    // MARK: Views
    let urlLabel = TappableLabel()

    // MARK: Callback
    var onURLTap: ((URL) -> Void)?

    override func setup() {
        layout()
        urlLabel.onHypertextTapped = { [unowned self] in
            guard let safeUrl = self.url else { return }
            self.onURLTap?(safeUrl)
        }
    }

    func configure(data: DataType) {
        urlLabel.set(hypertext: data.absoluteString, in: data.absoluteString)
        url = data
    }

    private func layout() {
        contentView.add(subview: urlLabel)
        urlLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
        urlLabel.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor).isActive = true
        let topConstraint = urlLabel.topAnchor.constraint(equalTo: contentView.layoutMarginsGuide.topAnchor)
        topConstraint.priority = UILayoutPriority(999)
        topConstraint.isActive = true
        let bottomConstraint = urlLabel.bottomAnchor.constraint(equalTo: contentView.layoutMarginsGuide.bottomAnchor)
        bottomConstraint.priority = UILayoutPriority(999)
        bottomConstraint.isActive = true
        urlLabel.trailingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.trailingAnchor).isActive = true
        urlLabel.heightAnchor.constraint(greaterThanOrEqualToConstant: Size.componentHeight).isActive = true

        addIndicatorImageView()
    }
}

typealias NotificationDetailHeaderConfiguration = CellConfiguration<NotificationDetailHeaderCell, DefaultCellAppearance>
typealias NotificationDetailTitleBodyConfiguration = CellConfiguration<NotificationDetailTitleBodyCell, DefaultCellAppearance>
typealias NotificationDetailAdditionalTextConfiguration = CellConfiguration<NotificationDetailAdditionalTextCell, DefaultCellAppearance>
typealias NotificationDetailURLConfiguration = CellConfiguration<NotificationDetailURLCell, DefaultCellAppearance>

protocol NotificationDetailViewModelDelegate: class {
    func onNotificationDeletion()
}

class NotificationDetailViewModel {

    let realmProvider: RealmProviding
    let notification: LocalNotifireNotification
    var token: NotificationToken?
    weak var delegate: NotificationDetailViewModelDelegate?
    var items: [CellConfiguring] = []

    init(realmProvider: RealmProviding, notification: LocalNotifireNotification) {
        self.realmProvider = realmProvider
        self.notification = notification
        self.items = NotificationDetailViewModel.createItems(from: notification)
        setupDeleteToken()
    }

    private func setupDeleteToken() {
        guard token == nil else { return }
        token = notification.observe({ [weak self] change in
            guard case .deleted = change else { return }
            self?.delegate?.onNotificationDeletion()
        })
    }

    private static func createItems(from notification: LocalNotifireNotification) -> [CellConfiguring] {
        guard let service = notification.service else { return [] }
        var result = [CellConfiguring]()

        let notificationDetailHeader = NotificationDetailHeader(serviceName: service.name, serviceImage: service.smallImage, notificationDate: notification.date, notificationLevel: notification.level)
        result.append(NotificationDetailHeaderConfiguration(item: notificationDetailHeader))

        let notificationTitleBody = NotificationDetailTitleBody(body: notification.body)
        result.append(NotificationDetailTitleBodyConfiguration(item: notificationTitleBody))

        if let additionalText = notification.text {
            result.append(NotificationDetailAdditionalTextConfiguration(item: additionalText))
        }

        if let url = notification.additionalURL {
            result.append(NotificationDetailURLConfiguration(item: url))
        }

        return result
    }

    func markNotificationAsRead() {
        NotificationReadUnreadManager.markNotificationAsRead(notification: notification, realm: realmProvider.realm)
    }
}
