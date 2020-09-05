//
//  LoginNavigationController.swift
//  Notifire
//
//  Created by David Bielik on 03/09/2020.
//  Copyright © 2020 David Bielik. All rights reserved.
//

import UIKit

class LoginNavigationController: UINavigationController, NavigationBarProviding {

    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        hideNavigationBar()

        navigationBar.tintColor = .customLabel
    }
}
