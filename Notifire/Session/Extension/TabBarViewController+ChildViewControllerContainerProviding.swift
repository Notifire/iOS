//
//  TabBarViewController+ChildViewControllerContainerProviding.swift
//  Notifire
//
//  Created by David Bielik on 07/09/2020.
//  Copyright © 2020 David Bielik. All rights reserved.
//

import UIKit

extension TabBarViewController: ChildViewControllerContainerProviding {
    var childViewControllerContainerView: UIView {
        return containerView
    }
}
