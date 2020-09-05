//
//  UIColorExtension.swift
//  Notifire
//
//  Created by David Bielik on 27/08/2018.
//  Copyright © 2018 David Bielik. All rights reserved.
//

import UIKit

extension UIColor {

    convenience init(red: CGFloat, green: CGFloat, blue: CGFloat) {
        let divisor: CGFloat = 255
        self.init(red: red/divisor, green: green/divisor, blue: blue/divisor, alpha: 1.0)
    }

    static let backgroundColor = UIColor(red: 255, green: 250, blue: 247)
    static let backgroundAccentColor = UIColor.white
    static let spinnerColor = UIColor(red: 200, green: 200, blue: 200)
    static let textFieldBorderColor = UIColor(red: 234, green: 234, blue: 234)
    static let textFieldBackgroundColor = UIColor(red: 247, green: 242, blue: 239)
    static let notifireMainColor = UIColor(red: 255, green: 119, blue: 0)
    static let barTintColor = UIColor.black
    static let tabBarButtonSelectedColor = UIColor.black
    static let tabBarButtonDeselectedColor = UIColor(red: 50, green: 50, blue: 50)
}
