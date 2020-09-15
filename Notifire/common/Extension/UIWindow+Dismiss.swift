//
//  UIWindow+Dismiss.swift
//  Notifire
//
//  Created by David Bielik on 15/09/2020.
//  Copyright © 2020 David Bielik. All rights reserved.
//

import UIKit

extension UIWindow {

    /// Removes the window from the window hierarchy
    /// https://stackoverflow.com/a/59988501/4249857
    func dismiss() {
        isHidden = true

        if #available(iOS 13, *) {
            windowScene = nil
        }
    }
}
