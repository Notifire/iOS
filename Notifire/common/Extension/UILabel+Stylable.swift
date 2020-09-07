//
//  UILabel+Stylable.swift
//  Notifire
//
//  Created by David Bielik on 03/09/2020.
//  Copyright © 2020 David Bielik. All rights reserved.
//

import UIKit

enum LabelStyle {
    case primary
    case secondary
    case largeTitle
    case title
    case negative
    case alertTitle
    case alertInformation
    case alertAction
    case informationHeader
    case heavyTitle
    case secureInformation

    case semiboldCellTitle
    case dimmedInformation
    case cellInformation
    case cellSubtitle
    case centeredLightInformation
    case emoji
    case negativeMedium
    case notifirePositive
}

extension UILabel: Stylable {
    typealias Style = LabelStyle

    convenience init(style: LabelStyle) {
        self.init(frame: .zero)
        set(style: style)
    }

    // swiftlint:disable function_body_length
    func set(style: UILabel.Style) {
        numberOfLines = 0
        switch style {
        case .primary:
            textColor = .compatibleLabel
            font = UIFont.systemFont(ofSize: 15)
        case .secondary:
            textColor = .compatibleSecondaryLabel
            font = UIFont.systemFont(ofSize: 14)
        case .largeTitle:
            textColor = .compatibleLabel
            font = UIFont.systemFont(ofSize: 28, weight: .bold)
        case .title:
            textColor = .compatibleLabel
            font = UIFont.systemFont(ofSize: 20, weight: .bold)
        case .negative:
            textColor = UIColor.red.withAlphaComponent(0.9)
            font = UIFont.systemFont(ofSize: 14)
            textAlignment = .left
        case .alertTitle:
            textColor = .compatibleLabel
            font = UIFont.systemFont(ofSize: 19, weight: .light)
            numberOfLines = 2
            textAlignment = .center
        case .alertInformation:
            textColor = .compatibleSecondaryLabel
            numberOfLines = 0
            font = UIFont.systemFont(ofSize: 14, weight: .light)
            textAlignment = .center
        case .alertAction:
            textColor = .primary
            numberOfLines = 1
            font = UIFont.systemFont(ofSize: 15, weight: .medium)
            textAlignment = .center
        case .informationHeader:
            textColor = .compatibleLabel
            font = UIFont.systemFont(ofSize: 16)
        case .heavyTitle:
            textColor = .compatibleLabel
            font = UIFont.systemFont(ofSize: 17, weight: .heavy)
        case .secureInformation:
            textColor = .compatibleSecondaryLabel
            font = UIFont.systemFont(ofSize: 14)
            textAlignment = .justified
            numberOfLines = 0

        case .semiboldCellTitle:
            textColor = .compatibleLabel
            font = UIFont.systemFont(ofSize: 17, weight: .semibold)
        case .dimmedInformation:
            textColor = UIColor.black.withAlphaComponent(0.8)
            font = UIFont.systemFont(ofSize: 17)
        case .cellInformation:
            textColor = .compatibleLabel
            font = UIFont.systemFont(ofSize: 15)
        case .cellSubtitle:
            textColor = .compatibleSecondaryLabel
            font = UIFont.systemFont(ofSize: 14)
        case .centeredLightInformation:
            textColor = .compatibleLabel
            font = UIFont.systemFont(ofSize: 12, weight: UIFont.Weight.light)
            textAlignment = .center
        case .emoji:
            font = UIFont.systemFont(ofSize: 24)
            textAlignment = .center
        case .negativeMedium:
            textColor = UIColor.compatibleRed.withAlphaComponent(0.9)
            font = UIFont.systemFont(ofSize: 16, weight: .medium)
            textAlignment = .center
        case .notifirePositive:
            textColor = .primary
            font = UIFont.systemFont(ofSize: 16)
            textAlignment = .left
        }
    }
    // swiftlint:enable function_body_length

}
