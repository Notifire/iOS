//
//  ServiceHeaderView.swift
//  Notifire
//
//  Created by David Bielik on 09/11/2018.
//  Copyright © 2018 David Bielik. All rights reserved.
//

import UIKit

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
    let serviceNameLabel = UILabel(style: .title)

    let serviceImageView = RoundedShadowImageView(image: nil)

    let floatingContentView = UIView()

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
        serviceImageView.widthAnchor.constraint(equalTo: floatingContentView.widthAnchor, multiplier: 0.35).isActive = true
        serviceImageView.centerXAnchor.constraint(equalTo: floatingContentView.centerXAnchor).isActive = true

        floatingContentView.add(subview: serviceNameLabel)
        serviceNameLabel.centerXAnchor.constraint(equalTo: floatingContentView.centerXAnchor).isActive = true
        serviceNameLabel.topAnchor.constraint(equalTo: serviceImageView.bottomAnchor, constant: 1.5 * floatingDistanceFromTop).isActive = true
        serviceNameLabel.bottomAnchor.constraint(equalTo: floatingContentView.bottomAnchor, constant: -floatingDistanceFromTop * 2).isActive = true
    }

    private func updateUI() {
        guard let service = service else { return }
        serviceNameLabel.text = service.name
        serviceImageView.image = service.image
    }
}
