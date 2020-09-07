//
//  BottomNavigatorLabelContaining.swift
//  Notifire
//
//  Created by David Bielik on 03/09/2020.
//  Copyright © 2020 David Bielik. All rights reserved.
//

import UIKit

protocol BottomNavigatorLabelContaining: BottomNavigatorContaining {
    var bottomNavigatorLabel: UILabel { get }
}

extension BottomNavigatorLabelContaining {

    func addBottomNavigatorLabel() {
        bottomNavigator.add(subview: bottomNavigatorLabel)
        bottomNavigatorLabel.centerXAnchor.constraint(equalTo: bottomNavigator.centerXAnchor).isActive = true
        bottomNavigatorLabel.centerYAnchor.constraint(equalTo: bottomNavigator.centerYAnchor).isActive = true
    }
}
