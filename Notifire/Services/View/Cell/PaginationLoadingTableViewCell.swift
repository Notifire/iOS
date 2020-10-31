//
//  PaginationLoadingTableViewCell.swift
//  Notifire
//
//  Created by David Bielik on 30/09/2020.
//  Copyright © 2020 David Bielik. All rights reserved.
//

import UIKit

class PaginationLoadingTableViewCell: BaseTableViewCell, Reusable {

    // MARK: - Properties
    static var reuseIdentifier: String = "PaginationLoadingTableViewCell"

    lazy var loadingIndicator: UIActivityIndicatorView = {
        let style: UIActivityIndicatorView.Style
        if #available(iOS 13.0, *) {
            style = .medium
        } else {
            style = .gray
        }
        let control = UIActivityIndicatorView(style: style)
        control.hidesWhenStopped = true
        control.startAnimating()
        return control
    }()

    // MARK: - Inherited
    override open func setup() {
        super.setup()
        selectionStyle = .none

        layout()
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        loadingIndicator.startAnimating()
    }

    // MARK: - Private
    private func layout() {
        contentView.add(subview: loadingIndicator)
        loadingIndicator.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).isActive = true
        loadingIndicator.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
    }
}