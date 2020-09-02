//
//  BottomNavigatorViewController.swift
//  Notifire
//
//  Created by David Bielik on 26/08/2018.
//  Copyright © 2018 David Bielik. All rights reserved.
//

import UIKit

/// A view controller class that generalizes view controllers that contain some navigation in the bottom "Tab bar"
class BottomNavigatorViewController: BaseViewController {

    // MARK: - Properties
    // MARK: Views
    let bottomNavigator: ConstrainableView = {
        let view = ConstrainableView()
        view.backgroundColor = .compatibleSystemBackground
        view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        view.layer.cornerRadius = 4
        return view
    }()

    // MARK: - Inherited
    override func setupSubviews() {
        view.backgroundColor = .compatibleSystemBackground

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
}

class BottomNavigatorLabelViewController: BottomNavigatorViewController {

    // MARK: - Properties
    lazy var tappableLabel: TappableLabel = {
        let label = TappableLabel()
        label.set(style: .primary)
        return label
    }()

    // MARK: - Inherited
    override func setupSubviews() {
        super.setupSubviews()

        // Tappable Label
        bottomNavigator.addSubview(tappableLabel)
        tappableLabel.translatesAutoresizingMaskIntoConstraints = false
        tappableLabel.centerXAnchor.constraint(equalTo: bottomNavigator.centerXAnchor).isActive = true
        tappableLabel.centerYAnchor.constraint(equalTo: bottomNavigator.centerYAnchor).isActive = true
    }
}
