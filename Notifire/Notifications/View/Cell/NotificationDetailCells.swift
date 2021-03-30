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
    let serviceImageURL: URL?
    let notificationDate: Date
    let notificationLevel: NotificationLevel
}

class NotificationDetailHeaderCell: BaseTableViewCell, CellConfigurable {

    typealias DataType = NotificationDetailHeader

    enum DateStyle {
        case compact
        case expanded

        var formatStyle: DateFormatStyle {
            switch self {
            case .compact: return DateFormatStyle.completeNoSec
            case .expanded: return DateFormatStyle.complete
            }
        }

        mutating func swapStyle() {
            switch self {
            case .compact: self = .expanded
            case .expanded: self = .compact
            }
        }
    }

    // MARK: - Properties
    var date = Date()
    var dateStyle: DateStyle = .compact {
        didSet {
            UIView.transition(with: dateLabel, duration: 0.2, options: [.transitionCrossDissolve], animations: {
                self.dateLabel.text = self.date.string(with: self.dateStyle.formatStyle)
            }, completion: nil)
        }
    }

    // MARK: Views
    lazy var serviceImageView = RoundedEmojiImageView(image: nil)
    lazy var serviceNameLabel: UILabel = {
        let label = UILabel(style: .title)
        label.numberOfLines = 0
        return label
    }()
    lazy var dateLabel = UILabel(style: .cellSubtitle)

    override func setup() {
        layout()
    }

    func configure(data: DataType) {
        serviceImageView.roundedImageView.sd_setImage(with: data.serviceImageURL, placeholderImage: LocalService.defaultImage, options: [], completed: nil)
        serviceNameLabel.text = data.serviceName
        serviceImageView.set(level: data.notificationLevel)
        dateStyle = .compact
        date = data.notificationDate
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
        serviceNameLabel.bottomAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
        serviceNameLabel.trailingAnchor.constraint(equalTo: serviceImageView.leadingAnchor).isActive = true

        contentView.add(subview: dateLabel)
        dateLabel.leadingAnchor.constraint(equalTo: serviceNameLabel.leadingAnchor).isActive = true
        dateLabel.topAnchor.constraint(equalTo: serviceNameLabel.bottomAnchor).isActive = true
    }
}

class NotificationDetailTextCell: BaseTableViewCell, CellConfigurable, NotificationDetailOptionallyDisplaying {
    typealias DataType = String

    // MARK: - Properties
    // MARK: NotificationDetailOptionallyDisplaying
    class var indicatorImage: UIImage { return UIImage() }
    class var indicatorImageSystemName: String { return "text.bubble" }

    // MARK: Views
    lazy var notificationBodyTextView: UITextView = {
        let view = UITextView()
        view.isEditable = false
        view.isScrollEnabled = false
        view.textColor = .compatibleLabel
        view.font = UIFont.systemFont(ofSize: 16)
        return view
    }()

    override func setup() {
        layout()
    }

    func configure(data: DataType) {
        notificationBodyTextView.text = data
    }

    private func layout() {
        contentView.add(subview: notificationBodyTextView)
        notificationBodyTextView.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor).isActive = true
        notificationBodyTextView.topAnchor.constraint(equalTo: contentView.layoutMarginsGuide.topAnchor).isActive = true
        notificationBodyTextView.bottomAnchor.constraint(equalTo: contentView.layoutMarginsGuide.bottomAnchor).isActive = true
        notificationBodyTextView.trailingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.trailingAnchor).isActive = true

        addIndicatorImageView()
    }
}

class NotificationDetailAdditionalTextCell: NotificationDetailTextCell {
    override class var indicatorImageSystemName: String { return "doc.plaintext" }
}

protocol NotificationDetailOptionallyDisplaying {
    static var indicatorImage: UIImage { get }
    static var indicatorImageSystemName: String { get }
}

extension NotificationDetailOptionallyDisplaying where Self: BaseTableViewCell {
    func addIndicatorImageView() {
        let selfType = type(of: self)
        let indicatorImageView = UIImageView(systemName: selfType.indicatorImageSystemName, compatibleNotifireImage: selfType.indicatorImage)
        let imageWidth = Size.Image.indicator
        let distanceFromContentLeadingAnchor = (Size.Cell.wideSideMargin - imageWidth) / 2
        contentView.add(subview: indicatorImageView)
        indicatorImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: distanceFromContentLeadingAnchor).isActive = true
        indicatorImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
        indicatorImageView.heightAnchor.constraint(equalTo: indicatorImageView.widthAnchor).isActive = true
        indicatorImageView.widthAnchor.constraint(equalToConstant: imageWidth).isActive = true
    }
}

class NotificationDetailURLCell: BaseTableViewCell, CellConfigurable, NotificationDetailOptionallyDisplaying {
    typealias DataType = URL

    // MARK: - Properties
    var url: DataType?

    // MARK: NotificationDetailIndicatorCell
    static var indicatorImage: UIImage { return #imageLiteral(resourceName: "link") }
    static var indicatorImageSystemName: String { return "link" }

    // MARK: Views
    let urlLabel = TappableLabel()

    // MARK: Callback
    var onURLTap: ((URL) -> Void)?

    override func setup() {
        layout()
        urlLabel.numberOfLines = 6
        urlLabel.lineBreakMode = .byTruncatingTail
        urlLabel.adjustsFontSizeToFitWidth = false
        urlLabel.onHypertextTapped = { [weak self] in
            guard let safeUrl = self?.url else { return }
            self?.onURLTap?(safeUrl)
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
typealias NotificationDetailTitleBodyConfiguration = CellConfiguration<NotificationDetailTextCell, DefaultCellAppearance>
typealias NotificationDetailAdditionalTextConfiguration = CellConfiguration<NotificationDetailAdditionalTextCell, DefaultCellAppearance>
typealias NotificationDetailURLConfiguration = CellConfiguration<NotificationDetailURLCell, DefaultCellAppearance>

protocol NotificationDetailViewModelDelegate: class {
    func onNotificationDeletion()
}
import StoreKit
class NotificationDetailViewModel: ViewModelRepresenting {

    // MARK: - Properties
    let realmProvider: RealmProviding
    let unreadNotificationsObserver: NotificationsUnreadCountObserver?
    let userSession: UserSession

    let notification: LocalNotifireNotification
    var items: [CellConfiguring] = []

    var token: NotificationToken?

    weak var delegate: NotificationDetailViewModelDelegate?

    // MARK: Static
    static let numberOfOpenedNotificationsForReview = 250

    // MARK: - Initialization
    /// - Parameters:
    ///     - serviceUnreadCount: Whether to count the number of unread notifications for the notification's service or for notifications from all services.
    ///     - markAsRead: Whether to mark the notification as read in the init of VM. Default value is `true`
    init(realmProvider: RealmProviding, notification: LocalNotifireNotification, userSession: UserSession, serviceUnreadCount: Bool, markAsRead: Bool) {
        self.realmProvider = realmProvider
        self.notification = notification
        self.userSession = userSession
        self.items = NotificationDetailViewModel.createItems(from: notification)
        if markAsRead {
            NotificationReadUnreadManager.markNotificationAsRead(notification: notification, realm: realmProvider.realm)
        }
        if let serviceID = notification.currentServiceID, serviceUnreadCount {
            // currentServiceID always contains a value.
            self.unreadNotificationsObserver = ServiceNotificationsUnreadCountObserver(realmProvider: realmProvider, serviceID: serviceID)
        } else {
            self.unreadNotificationsObserver = NotificationsUnreadCountObserver(realmProvider: realmProvider)
        }
        setupDeleteToken()
    }

    // MARK: - Private
    private func setupDeleteToken() {
        guard token == nil else { return }
        token = notification.observe({ [weak self] change in
            guard case .deleted = change else { return }
            self?.delegate?.onNotificationDeletion()
        })
    }

    private static func createItems(from notification: LocalNotifireNotification) -> [CellConfiguring] {
        var result = [CellConfiguring]()

        if let service = notification.service {
            let imageURL = URL(string: service.largeImageURLString ?? "")
            let notificationDetailHeader = NotificationDetailHeader(serviceName: service.name, serviceImageURL: imageURL, notificationDate: notification.date, notificationLevel: notification.level)
            result.append(NotificationDetailHeaderConfiguration(item: notificationDetailHeader))
        } else if let serviceSnippet = notification.serviceSnippet {
            let imageURL = URL(string: serviceSnippet.largeImageURLString ?? "")
            let notificationDetailHeader = NotificationDetailHeader(
                serviceName: serviceSnippet.name,
                serviceImageURL: imageURL,
                notificationDate: notification.date,
                notificationLevel: notification.level
            )
            result.append(NotificationDetailHeaderConfiguration(item: notificationDetailHeader))
        } else {
            return []
        }

        result.append(NotificationDetailTitleBodyConfiguration(item: notification.body ?? ""))

        if let additionalText = notification.text {
            result.append(NotificationDetailAdditionalTextConfiguration(item: additionalText))
        }

        if let url = notification.additionalURL {
            result.append(NotificationDetailURLConfiguration(item: url))
        }

        return result
    }

    /// Bump the number of read notifications in `UserSessionSettings`
    func bumpNumberOfReadNotificationsInSettings() {
        userSession.settings.numberOfOpenedNotifications += 1

        if userSession.settings.numberOfOpenedNotifications >= Self.numberOfOpenedNotificationsForReview &&
            userSession.settings.lastVersionPromptedForReview != Config.appVersion {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
                guard let `self` = self else { return }
                SKStoreReviewController.requestReview()
                // Set the last prompt version
                self.userSession.settings.lastVersionPromptedForReview = Config.appVersion
                // Reset counter
                self.userSession.settings.numberOfOpenedNotifications = 0
            }
        }
    }
}
