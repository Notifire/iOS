//
//  NotificationsEmptyStateView.swift
//  Notifire
//
//  Created by David Bielik on 13/12/2018.
//  Copyright © 2018 David Bielik. All rights reserved.
//

import UIKit

class NotificationsEmptyStateView: ConstrainableView, CenterStackViewPresenting {
    
    // MARK: - Properties
    // MARK: Views
    let titleLabel: UILabel = {
        let label = UILabel(style: .title)
        label.textAlignment = .center
        label.numberOfLines = 1
        return label
    }()
    
    let textLabel: UILabel = {
        let label = UILabel(style: .dimmedInformation)
        label.textAlignment = .center
        return label
    }()
    
    // MARK: - Inherited
    override func setupSubviews() {
        layout()
        backgroundColor = .backgroundColor
    }
    
    private func layout() {
        let stackView = insertStackView(arrangedSubviews: [titleLabel, textLabel], spacing: Size.textFieldSpacing)
        stackView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        stackView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
    }
    
    func set(title: String, text: String) {
        titleLabel.text = title
        textLabel.text = text
    }
}
