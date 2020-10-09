//
//  ServiceTableViewCell.swift
//  Notifire
//
//  Created by David Bielik on 16/09/2020.
//  Copyright © 2020 David Bielik. All rights reserved.
//

import UIKit
import SkeletonView

class ServiceTableViewCell: BaseTableViewCell, Reusable {
    // MARK: - Properties
    // MARK: Static
    static var reuseIdentifier = "ServiceTableViewCell"

    // MARK: Views
    let serviceImageView = RoundedImageView()
    let serviceNameLabel = UILabel(style: .semiboldCellTitle)
    let unreadNotificationsLabel = UILabel(style: .cellSubtitle)

    // MARK: Inherited
    override open func setup() {
        setLayout(margins: UIEdgeInsets(top: Size.Cell.extendedSideMargin/2, left: Size.Cell.extendedSideMargin, bottom: Size.Cell.extendedSideMargin/2, right: Size.Cell.narrowSideMargin))
        backgroundColor = .compatibleSystemBackground
        layout()

        isSkeletonable = true
        serviceImageView.isSkeletonable = true
        serviceNameLabel.isSkeletonable = true
    }

    // MARK: Private
    private func layout() {
        contentView.add(subview: serviceImageView)
        serviceImageView.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor).isActive = true
        let serviceImageHeightConstraint = serviceImageView.heightAnchor.constraint(equalToConstant: Size.Image.mediumService)
        serviceImageHeightConstraint.priority = .init(900)
        serviceImageHeightConstraint.isActive = true
        serviceImageView.widthAnchor.constraint(equalTo: serviceImageView.heightAnchor).isActive = true
        let imageTopConstraint: NSLayoutConstraint
        let imageBottomConstraint: NSLayoutConstraint
        if #available(iOS 13, *) {
            imageTopConstraint = serviceImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: Size.Cell.extendedSideMargin/2)
            imageBottomConstraint = serviceImageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -Size.Cell.extendedSideMargin/2)
        } else {
            imageTopConstraint = serviceImageView.topAnchor.constraint(equalTo: contentView.layoutMarginsGuide.topAnchor)
            imageBottomConstraint = serviceImageView.bottomAnchor.constraint(equalTo: contentView.layoutMarginsGuide.bottomAnchor)
        }
        imageTopConstraint.priority = UILayoutPriority(rawValue: 999)
        imageTopConstraint.isActive = true
        imageBottomConstraint.isActive = true

        contentView.add(subview: serviceNameLabel)
        serviceNameLabel.leadingAnchor.constraint(equalTo: serviceImageView.trailingAnchor, constant: Size.Cell.extendedSideMargin).isActive = true
        serviceNameLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true

        contentView.add(subview: unreadNotificationsLabel)
        unreadNotificationsLabel.trailingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.trailingAnchor).isActive = true
        unreadNotificationsLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
        unreadNotificationsLabel.leadingAnchor.constraint(equalTo: serviceNameLabel.trailingAnchor).isActive = true
        unreadNotificationsLabel.setContentHuggingPriority(.defaultHigh, for: .horizontal)
    }

    // MARK: Update model
    func configure(from representable: ServiceRepresentable) {
        // TODO: Add downloader
        serviceImageView.image = LocalService.defaultImage
        serviceNameLabel.text = representable.name
        // FIXME:
//        let unreadCount = service.notifications.filter(LocalNotifireNotification.isReadPredicate).count
//        let unreadText = unreadCount == 0 ? "" : "\(unreadCount)"
//        unreadNotificationsLabel.text = unreadText
    }
}
