//
//  KeyboardDismissing.swift
//  Notifire
//
//  Created by David Bielik on 28/08/2018.
//  Copyright © 2018 David Bielik. All rights reserved.
//

import UIKit

protocol KeyboardDismissing {
    var keyboardDismissableView: UIView { get set }
}

extension KeyboardDismissing {
    func setupKeyboardDismissing() {

    }
}

extension KeyboardDismissing where Self: UIView {

}
