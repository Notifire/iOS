//
//  NotifireNavigationController.swift
//  Notifire
//
//  Created by David Bielik on 10/12/2018.
//  Copyright © 2018 David Bielik. All rights reserved.
//

import UIKit

class NotifireNavigationController: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationBar.titleTextAttributes = [
            NSAttributedString.Key.font: UIFont.systemFont(ofSize: 17, weight: UIFont.Weight.heavy),
            NSAttributedString.Key.foregroundColor: UIColor.compatibleLabel
        ]
        view.backgroundColor = .compatibleSystemBackground
        navigationBar.barTintColor = .compatibleSystemBackground
        navigationBar.tintColor = .compatibleLabel
    }
}

extension NotifireNavigationController: Reselectable {
    func reselect() -> Bool {
        guard viewControllers.count > 1 else { return false }
        popToRootViewController(animated: true)
        return true
    }
}
