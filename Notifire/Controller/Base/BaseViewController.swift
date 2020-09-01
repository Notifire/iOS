//
//  BaseViewController.swift
//  Notifire
//
//  Created by David Bielik on 26/08/2018.
//  Copyright © 2018 David Bielik. All rights reserved.
//

import UIKit

class BaseViewController: UIViewController {

    // MARK: - Inherited
    override func viewDidLoad() {
        super.viewDidLoad()

        setupSubviews()
    }

    // MARK: - Open
    /// Override this function if you want to provide custom view logic (e.g. layout). Called inside `viewDidLoad`. Default implementation does nothing.
    open func setupSubviews() {

    }
}
