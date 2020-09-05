//
//  VMView.swift
//  Notifire
//
//  Created by David Bielik on 02/09/2020.
//  Copyright © 2020 David Bielik. All rights reserved.
//

import UIKit

class VMView<ViewModel>: UIView {

    // MARK: - Properties
    let viewModel: ViewModel

    // MARK: - Initialization
    init(viewModel: ViewModel) {
        self.viewModel = viewModel
        super.init(frame: .zero)
        setupSubviews()
    }

    required init?(coder: NSCoder) { fatalError("VMView init from coder not implemented") }

    // MARK: - Open
    /// Override this function if you want to provide custom view logic (layout). Called after initialization. Default implementation does nothing.
    open func setupSubviews() {}
}
