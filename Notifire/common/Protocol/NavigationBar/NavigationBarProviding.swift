//
//  NavigationBarProviding.swift
//  Notifire
//
//  Created by David Bielik on 03/09/2020.
//  Copyright © 2020 David Bielik. All rights reserved.
//

import UIKit

protocol NavigationBarProviding {
    func hideNavigationBar()
    func showNavigationBar()
}

extension UINavigationController: NavigationBarProviding {

    func hideNavigationBar() {
        if #available(iOS 13.0, *) {
            let appearance = UINavigationBarAppearance()
            appearance.configureWithTransparentBackground()
            appearance.backgroundColor = .clear
            if let attributes = navigationBar.titleTextAttributes {
                appearance.titleTextAttributes = attributes
            }
            navigationBar.standardAppearance = appearance
            navigationBar.compactAppearance = appearance
            navigationBar.scrollEdgeAppearance = appearance
        } else {
            navigationBar.shadowImage = UIImage()
            navigationBar.setBackgroundImage(UIImage(), for: .default)
            navigationBar.barTintColor = .clear
        }
        navigationBar.isTranslucent = true
    }

    func showNavigationBar() {
        if #available(iOS 13.0, *) {
            let appearance = UINavigationBarAppearance()
            appearance.configureWithDefaultBackground()
            appearance.backgroundColor = .compatibleSystemBackground
            if let attributes = navigationBar.titleTextAttributes {
                appearance.titleTextAttributes = attributes
            }
            navigationBar.standardAppearance = appearance
            navigationBar.compactAppearance = appearance
            navigationBar.scrollEdgeAppearance = appearance
        } else {
            navigationBar.shadowImage = nil
            navigationBar.barTintColor = .compatibleSystemBackground
        }
        navigationBar.isTranslucent = false
    }
}
