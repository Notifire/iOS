//
//  BottomNavigatorViewController.swift
//  Notifire
//
//  Created by David Bielik on 26/08/2018.
//  Copyright © 2018 David Bielik. All rights reserved.
//

import UIKit

class BottomNavigatorViewController: BaseViewController {

    // MARK: - Properties
    // MARK: Views
    let bottomNavigator: ConstrainableView = {
        let view = ConstrainableView()
        view.backgroundColor = .backgroundColor
        view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        view.layer.cornerRadius = 4
        return view
    }()

    let tappableLabel = TappableLabel(fontSize: 13)

    // MARK: - Inherited
    override func setupSubviews() {
        view.backgroundColor = .backgroundColor

        // navigator
        view.addSubview(bottomNavigator)
        bottomNavigator.backgroundColor = .backgroundAccentColor
        bottomNavigator.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor).isActive = true
        bottomNavigator.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor).isActive = true
        bottomNavigator.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        bottomNavigator.heightAnchor.constraint(equalToConstant: Size.Navigator.height).isActive = true

        // separator
        let hairlineView = HairlineView()
        bottomNavigator.addSubview(hairlineView)
        hairlineView.leadingAnchor.constraint(equalTo: bottomNavigator.leadingAnchor).isActive = true
        hairlineView.trailingAnchor.constraint(equalTo: bottomNavigator.trailingAnchor).isActive = true
        hairlineView.topAnchor.constraint(equalTo: bottomNavigator.topAnchor).isActive = true

        // Tappable Label
        bottomNavigator.addSubview(tappableLabel)
        tappableLabel.translatesAutoresizingMaskIntoConstraints = false
        tappableLabel.centerXAnchor.constraint(equalTo: bottomNavigator.centerXAnchor).isActive = true
        tappableLabel.centerYAnchor.constraint(equalTo: bottomNavigator.centerYAnchor).isActive = true
        tappableLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTapLabel(recognizer:))))
    }

    // MARK: - Event Handlers
    @objc private func didTapLabel(recognizer: UITapGestureRecognizer) {
        guard recognizer.didTapAttributedText(in: tappableLabel) else { return }
        didTapTappableLabel()
    }

    // MARK: - Open
    open func didTapTappableLabel() {

    }
}
