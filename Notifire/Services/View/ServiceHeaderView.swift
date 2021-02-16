//
//  ServiceHeaderView.swift
//  Notifire
//
//  Created by David Bielik on 09/11/2018.
//  Copyright © 2018 David Bielik. All rights reserved.
//

import UIKit
import SDWebImage

class ServiceHeaderView: ConstrainableView {

    // MARK: - Properties
    var floatingTopToTopConstraint: NSLayoutConstraint!

    // MARK: Model
    var service: LocalService? {
        didSet {
            updateUI()
        }
    }

    // MARK: Views
    lazy var serviceNameLabel: UILabel = {
        let label = UILabel(style: .title)
        label.adjustsFontSizeToFitWidth = false
        label.lineBreakMode = .byTruncatingTail
        label.numberOfLines = 2
        label.textAlignment = .center
        return label
    }()

    lazy var serviceImageView: RoundedShadowImageView = RoundedShadowImageView(image: nil)

    lazy var floatingContentView: UIView = UIView()

    // MARK: - Lifecycle
    override func setupSubviews() {
        layout()
    }

    // MARK: - Private
    private func layout() {
        add(subview: floatingContentView)
        floatingTopToTopConstraint = floatingContentView.topAnchor.constraint(equalTo: topAnchor)
        floatingTopToTopConstraint.isActive = true
        floatingContentView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        floatingContentView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        heightAnchor.constraint(equalTo: floatingContentView.heightAnchor).isActive = true

        let floatingDistanceFromTop: CGFloat = Size.componentHeight / 2
        floatingContentView.add(subview: serviceImageView)
        serviceImageView.topAnchor.constraint(equalTo: floatingContentView.topAnchor, constant: floatingDistanceFromTop).isActive = true
        serviceImageView.heightAnchor.constraint(equalTo: serviceImageView.widthAnchor).isActive = true
        serviceImageView.widthAnchor.constraint(equalToConstant: Size.Image.largeService).isActive = true
        serviceImageView.centerXAnchor.constraint(equalTo: floatingContentView.centerXAnchor).isActive = true

        floatingContentView.add(subview: serviceNameLabel)
        serviceNameLabel.centerXAnchor.constraint(equalTo: floatingContentView.centerXAnchor).isActive = true
        serviceNameLabel.topAnchor.constraint(equalTo: serviceImageView.bottomAnchor, constant: 1.5 * floatingDistanceFromTop).isActive = true
        serviceNameLabel.bottomAnchor.constraint(equalTo: floatingContentView.bottomAnchor, constant: -floatingDistanceFromTop * 2).isActive = true
        serviceNameLabel.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.56).isActive = true
    }

    private func updateUI() {
        guard let service = service else { return }
        serviceNameLabel.text = service.name
        if let urlString = service.largeImageURLString, let url =  URL(string: urlString) {
            // Image URLs exist <=> the user has setup an image for this service
            if let smallImage = SDImageCache.shared.imageFromCache(forKey: service.smallImageURLString, options: [], context: nil) {
                // Use small image as placeholder
                serviceImageView.roundedImageView.sd_setImage(with: url, placeholderImage: smallImage, options: [], context: [:])
            } else {
                // Use default placeholder
                serviceImageView.roundedImageView.sd_setImage(with: url, placeholderImage: LocalService.defaultImage, options: [], context: [:])
            }
        } else {
            serviceImageView.image = LocalService.defaultImage
        }
    }
}
