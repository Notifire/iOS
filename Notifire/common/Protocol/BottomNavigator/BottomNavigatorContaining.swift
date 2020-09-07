//
//  BottomNavigatorContaining.swift
//  Notifire
//
//  Created by David Bielik on 03/09/2020.
//  Copyright © 2020 David Bielik. All rights reserved.
//

import UIKit

/// Protocol representing a viewcontroller that contains a navigator view at the bottom.
/// - Note: the navigator can contain any other view (e.g. a tabbar buttons stackview)
protocol BottomNavigatorContaining {
    var bottomNavigator: UIView { get }
    var bottomNavigatorSuperview: UIView { get }
}

extension BottomNavigatorContaining {
    /// Adds the navigator to the bottom of the view
    func addBottomNavigator() {
        let view = bottomNavigatorSuperview
        // Bottom Navigator container
        let navigatorContainer = UIView()
        navigatorContainer.backgroundColor = .compatibleSystemBackground
        view.add(subview: navigatorContainer)
        navigatorContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        navigatorContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        navigatorContainer.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        navigatorContainer.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -Size.Tab.height).isActive = true

        // Bottom Navigator
        view.add(subview: bottomNavigator)
        bottomNavigator.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        bottomNavigator.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        bottomNavigator.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        bottomNavigator.topAnchor.constraint(equalTo: navigatorContainer.topAnchor).isActive = true

        // separator
        let hairlineView = HairlineView()
        bottomNavigator.addSubview(hairlineView)
        hairlineView.leadingAnchor.constraint(equalTo: bottomNavigator.leadingAnchor).isActive = true
        hairlineView.trailingAnchor.constraint(equalTo: bottomNavigator.trailingAnchor).isActive = true
        hairlineView.topAnchor.constraint(equalTo: bottomNavigator.topAnchor).isActive = true
    }

    func defaultBottomNavigatorView() -> UIView {
        let navigator = UIView()
        navigator.backgroundColor = .compatibleSystemBackground
        return navigator
    }
}

extension BottomNavigatorContaining where Self: UIViewController {
    var bottomNavigatorSuperview: UIView {
        return view
    }
}
