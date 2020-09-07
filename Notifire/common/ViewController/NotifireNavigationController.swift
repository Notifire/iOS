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
        view.backgroundColor = .compatibleBackgroundAccent
        navigationBar.barTintColor = .compatibleBackgroundAccent
        navigationBar.tintColor = .compatibleLabel
    }

    override func pushViewController(_ viewController: UIViewController, animated: Bool) {
        //(viewController as? UIViewController & NavigationBarDisplaying)?.showNavigationBar()
        super.pushViewController(viewController, animated: animated)
    }

    override func popViewController(animated: Bool) -> UIViewController? {
        let popped = super.popViewController(animated: animated)
        (popped as? UIViewController & NavigationBarDisplaying)?.hideNavigationBar()
        return popped
    }
}
