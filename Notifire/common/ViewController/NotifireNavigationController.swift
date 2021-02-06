//
//  NotifireNavigationController.swift
//  Notifire
//
//  Created by David Bielik on 10/12/2018.
//  Copyright © 2018 David Bielik. All rights reserved.
//

import UIKit

class NotifireNavigationController: UINavigationController {

    var navigationBarTintColor: UIColor = .compatibleLabel

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationBar.titleTextAttributes = TextAttributes.navigationTitle
        view.backgroundColor = .compatibleSystemBackground
        navigationBar.barTintColor = .compatibleSystemBackground
        navigationBar.tintColor = navigationBarTintColor
    }
}

extension NotifireNavigationController: Reselectable {
    func reselect() -> Bool {
        guard viewControllers.count > 1 else { return false }
        popToRootViewController(animated: true)
        return true
    }
}
