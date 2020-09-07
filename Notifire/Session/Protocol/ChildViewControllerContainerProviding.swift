//
//  ChildViewControllerContainerProviding.swift
//  Notifire
//
//  Created by David Bielik on 07/09/2020.
//  Copyright © 2020 David Bielik. All rights reserved.
//

import UIKit

/// Describes a construct that provides a container for some ChildVC
protocol ChildViewControllerContainerProviding {
    var childViewControllerContainerView: UIView { get }
}

extension ChildViewControllerContainerProviding where Self: UIViewController {
    // Embed a  view controller inside the container view
    func embed(viewController viewC: UIViewController) {
        // Add the child view controller
        add(childViewController: viewC, superview: childViewControllerContainerView)
        // Embed it inside our container view
        viewC.view.translatesAutoresizingMaskIntoConstraints = false
        viewC.view.embed(in: childViewControllerContainerView)
    }
}
