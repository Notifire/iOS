//
//  DeeplinkedVMViewController.swift
//  Notifire
//
//  Created by David Bielik on 19/11/2020.
//  Copyright © 2020 David Bielik. All rights reserved.
//

import UIKit

/// All Deeplink viewcontrollers should inherit from this class.
class DeeplinkedVMViewController<VM: UserSessionCreating & DeeplinkResponding>: VMViewController<VM>, NavigationBarDisplaying {

    // MARK: - Properties
    weak var delegate: DeeplinkedVMViewControllerDelegate?

    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .compatibleSystemBackground

        hideNavigationBar()
        setupSubviews()
    }

    open func setupSubviews() {
        navigationItem.leftBarButtonItem = ActionButton.createCloseCrossBarButtonItem(target: self, action: #selector(didPressCancelButton))
    }

    // MARK: Event Handlers
    @objc func didPressCancelButton() {
        delegate?.shouldCloseDeeplink()
    }
}
