//
//  UIColor+AppColors.swift
//  Notifire
//
//  Created by David Bielik on 02/09/2020.
//  Copyright © 2020 David Bielik. All rights reserved.
//

import UIKit

// MARK: - Custom Application Colors
extension UIColor {

    // MARK: - Initializers
    // swiftlint:disable identifier_name
    private convenience init(r: CGFloat, g: CGFloat, b: CGFloat, a: CGFloat = 1.0) {
        let divisor: CGFloat = 255
        self.init(red: r/divisor, green: g/divisor, blue: b/divisor, alpha: a)
    }
    // swiftlint:enable identifier_name

    private convenience init(same: CGFloat) {
        self.init(r: same, g: same, b: same)
    }

    /// Return light or dark color based on iOS version and userInterfaceStyle
    private static func from(light: UIColor, dark: UIColor) -> UIColor {
        // if iOS < 13.0 then return a light color
        guard #available(iOS 13, *) else { return light }

        // else return the color based on the interface style
        return UIColor { $0.userInterfaceStyle == .dark ? dark : light }
    }

    // MARK: - Colors
    public static let primary: UIColor = #colorLiteral(red: 1, green: 0.4666666667, blue: 0, alpha: 1)
    public static let tabBarButtonDeselected: UIColor = #colorLiteral(red: 0.7843137255, green: 0.7843137255, blue: 0.7843137255, alpha: 1)
    public static let outlineGray: UIColor = UIColor(r: 140, g: 140, b: 141)

    // MARK: Backgrounds
    // Sub iOS 13.0 backwards compatible colors
    public static var compatibleSystemBackground: UIColor = {
        guard #available(iOS 13, *) else { return #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1) }
        return .systemBackground
    }()

    public static var backgroundAccent: UIColor = {
        let diff: CGFloat = 6
        let max: CGFloat = 255
        return from(light: UIColor(same: max-diff), dark: UIColor(same: 2*diff))
    }()

    public static var compatibleSystemGroupedBackground: UIColor = {
        guard #available(iOS 13, *) else { return .groupTableViewBackground }
        return .systemGroupedBackground
    }()

    public static var compatibleSecondarySystemGroupedBackground: UIColor = {
           guard #available(iOS 13, *) else { return .white }
           return .secondarySystemGroupedBackground
       }()

    public static var compatibleTertiarySystemFill: UIColor = {
        guard #available(iOS 13, *) else { return #colorLiteral(red: 0.937254902, green: 0.937254902, blue: 0.9411764706, alpha: 1) }
        return .tertiarySystemFill
    }()

    // MARK: Separators
    public static var customSeparator: UIColor = {
        guard #available(iOS 13, *) else { return #colorLiteral(red: 0.2352941176, green: 0.2352941176, blue: 0.262745098, alpha: 0.29) }
        return .separator
    }()

    public static var customOpaqueSeparator: UIColor = {
        guard #available(iOS 13, *) else { return #colorLiteral(red: 0.7764705882, green: 0.7764705882, blue: 0.7843137255, alpha: 1) }
        return .opaqueSeparator
    }()

    // MARK: Labels
    public static var customLabel: UIColor = {
        guard #available(iOS 13, *) else { return .black }
        return .label
    }()

    public static var customSecondaryLabel: UIColor = {
        guard #available(iOS 13, *) else { return outlineGray }
        return .secondaryLabel
    }()
}
