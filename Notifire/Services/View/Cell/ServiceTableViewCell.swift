//
//  ServiceTableViewCell.swift
//  Notifire
//
//  Created by David Bielik on 16/09/2020.
//  Copyright © 2020 David Bielik. All rights reserved.
//

import UIKit
import SkeletonView
import SDWebImage

class ServiceTableViewCell: ReusableBaseTableViewCell {

    // MARK: Views
    let serviceImageView = RoundedImageView()
    lazy var serviceNameLabel: UILabel = {
        let label = UILabel(style: .semiboldCellTitle)
        label.isSkeletonable = true
        label.linesCornerRadius = 10
        label.numberOfLines = 1
        label.lineBreakMode = .byTruncatingTail
        label.adjustsFontSizeToFitWidth = false
        return label
    }()
    let unreadNotificationsLabel = UILabel(style: .cellSubtitle)

    // MARK: Inherited
    override open func setup() {
        setLayout(margins: UIEdgeInsets(top: Size.Cell.extendedSideMargin/2, left: Size.Cell.extendedSideMargin, bottom: Size.Cell.extendedSideMargin/2, right: Size.Cell.narrowSideMargin))
        backgroundColor = .compatibleSystemBackground
        layout()

        accessoryType = .disclosureIndicator
        layoutMargins = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 20)
        isSkeletonable = true
        serviceImageView.isSkeletonable = true

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
        // this constraint is used to correctly display a skeleton for this label
        // Note: if the constraint isn't used, the skeleton is misaligned / has wrong height
        let skeletonHeightConstraint = serviceNameLabel.heightAnchor.constraint(equalToConstant: 20)
        skeletonHeightConstraint.priority = .init(500)
        skeletonHeightConstraint.isActive = true

        contentView.add(subview: unreadNotificationsLabel)
        unreadNotificationsLabel.trailingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.trailingAnchor).isActive = true
        unreadNotificationsLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
        unreadNotificationsLabel.leadingAnchor.constraint(equalTo: serviceNameLabel.trailingAnchor).isActive = true
        unreadNotificationsLabel.setContentHuggingPriority(.defaultHigh, for: .horizontal)
    }

    // MARK: Update model
    func configure(from representable: ServiceRepresentable) {
        if let imageURL = representable.imageURL {
            serviceImageView.sd_setImage(with: imageURL, placeholderImage: LocalService.defaultImage, options: [], context: [:])
        } else {
            serviceImageView.image = LocalService.defaultImage
        }
        serviceNameLabel.text = representable.name
        if let local = representable as? LocalService, !local.isInvalidated {
            let unreadCount = local.notifications.filter(LocalNotifireNotification.isUnreadPredicate).count
            let unreadText = unreadCount == 0 ? "" : "\(unreadCount)"
            unreadNotificationsLabel.text = unreadText
        }
    }
}
