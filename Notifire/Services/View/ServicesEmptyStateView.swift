//
//  ServicesEmptyStateView.swift
//  Notifire
//
//  Created by David Bielik on 13/12/2018.
//  Copyright © 2018 David Bielik. All rights reserved.
//

import UIKit

class ServicesEmptyStateView: ConstrainableView, CenterStackViewPresenting {

    // MARK: - Properties
    // MARK: Views
    let titleLabel: UILabel = {
        let label = UILabel(style: .title)
        label.text = "You don't have any services. 😶"
        label.textAlignment = .center
        label.numberOfLines = 1
        return label
    }()

    let textLabel: UILabel = {
        let label = UILabel(style: .dimmedInformation)
        label.text = "What are you waiting for?"
        label.textAlignment = .center
        return label
    }()

    let serviceButton: UIButton = {
        let button = NotifireButton()
        button.setTitle("Create a service", for: .normal)
        return button
    }()

    // MARK: - Inherited
    override func setupSubviews() {
        layout()
        backgroundColor = .compatibleSystemBackground
    }

    private func layout() {
        let stackView = insertStackView(arrangedSubviews: [titleLabel, textLabel, serviceButton], spacing: Size.textFieldSpacing)
        stackView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        stackView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true

        stackView.setCustomSpacing(Size.componentSpacing * 2, after: textLabel)
    }
}
