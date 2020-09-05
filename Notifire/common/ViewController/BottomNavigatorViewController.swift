//
//  BottomNavigatorViewController.swift
//  Notifire
//
//  Created by David Bielik on 26/08/2018.
//  Copyright © 2018 David Bielik. All rights reserved.
//

import UIKit

/// A view controller class that generalizes view controllers that contain some navigation in the bottom "Tab bar"
class BottomNavigatorViewController: BaseViewController, BottomNavigatorContaining {

    // MARK: - Properties
    // MARK: Views
    let bottomNavigator: UIView = {
        let view = ConstrainableView()
        view.backgroundColor = .compatibleSystemBackground
        view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        view.layer.cornerRadius = 4
        return view
    }()

    // MARK: - Inherited
    override func setupSubviews() {
        view.backgroundColor = .compatibleSystemBackground

        addBottomNavigator()
    }
}

class BottomNavigatorLabelViewController: BottomNavigatorViewController, BottomNavigatorLabelContaining {

    // MARK: - Properties
    lazy var tappableLabel: TappableLabel = {
        let label = TappableLabel()
        label.set(style: .primary)
        return label
    }()

    // MARK: BottomNavigatorLabelContaining
    var bottomNavigatorLabel: UILabel {
        return tappableLabel
    }

    // MARK: - Inherited
    override func setupSubviews() {
        super.setupSubviews()

        addBottomNavigatorLabel()
    }
}
