//
//  NotifireActionNavigationController.swift
//  Notifire
//
//  Created by David Bielik on 12/10/2018.
//  Copyright © 2018 David Bielik. All rights reserved.
//

import UIKit

class NotifireActionNavigationController: UINavigationController {

    // MARK: - Inherited
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationBar.barTintColor = .compatibleBackgroundAccent
        navigationBar.prefersLargeTitles = true
        navigationItem.setHidesBackButton(true, animated: false)
        interactivePopGestureRecognizer?.isEnabled = false
    }
}
