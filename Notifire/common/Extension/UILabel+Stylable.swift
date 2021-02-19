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
    case connectionStatus
    case semiboldCellTitle
    case boldTinyCellTitle
    case cellTitle

    // Buttons
    case actionButton

    case dimmedInformation
    case centeredDimmedLightInformation
    case cellInformation
    case cellSubtitle
    case cellNotifirePositiveSubtitle
    case cellBodySemibold
    case centeredLightInformation
    case emoji
    case emojiSmall
    case negativeMedium
    case notifirePositive
    case warningTitle
}

extension UILabel: Stylable {
    typealias Style = LabelStyle

    convenience init(style: LabelStyle) {
        self.init(frame: .zero)
        set(style: style)
    }

    convenience init(style: LabelStyle, text: String = "", alignment: NSTextAlignment = .natural) {
        self.init(frame: .zero)
        set(style: style)
        self.text = text
        self.textAlignment = alignment
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
            font = UIFont.systemFont(ofSize: 21, weight: .bold)
            numberOfLines = 1
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
        case .centeredLightInformation:
            textColor = .compatibleLabel
            font = UIFont.systemFont(ofSize: 12, weight: UIFont.Weight.light)
            textAlignment = .center
        case .centeredDimmedLightInformation:
            textColor = UIColor.compatibleLabel.withAlphaComponent(0.8)
            font = UIFont.systemFont(ofSize: 13, weight: .light)
            textAlignment = .center
        case .connectionStatus:
            textColor = .white
            font = UIFont.systemFont(ofSize: 13, weight: UIFont.Weight.medium)
            textAlignment = .center
        case .semiboldCellTitle:
            textColor = .compatibleLabel
            font = UIFont.systemFont(ofSize: 17, weight: .semibold)
        case .boldTinyCellTitle:
            textColor = .compatibleLabel
            font = UIFont.systemFont(ofSize: 12, weight: .bold)
        case .cellTitle:
            textColor = .compatibleLabel
            font = UIFont.systemFont(ofSize: 16)

        // Buttons
        case .actionButton:
            textColor = .primary
            font = UIFont.systemFont(ofSize: 15, weight: .medium)

        case .dimmedInformation:
            textColor = UIColor.compatibleLabel.withAlphaComponent(0.8)
            font = UIFont.systemFont(ofSize: 17)
        case .cellInformation:
            textColor = .compatibleLabel
            font = UIFont.systemFont(ofSize: 15)
        case .cellSubtitle:
            textColor = .compatibleSecondaryLabel
            font = UIFont.systemFont(ofSize: 14)
        case .cellNotifirePositiveSubtitle:
            textColor = .primary
            font = UIFont.systemFont(ofSize: 13)
        case .cellBodySemibold:
            textColor = .compatibleLabel
            font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        case .emoji:
            font = UIFont.systemFont(ofSize: 24)
            textAlignment = .center
        case .emojiSmall:
            font = UIFont.systemFont(ofSize: 12)
            textAlignment = .center
        case .negativeMedium:
            textColor = UIColor.compatibleRed.withAlphaComponent(0.8)
            font = UIFont.systemFont(ofSize: 15, weight: .medium)
            textAlignment = .center
        case .notifirePositive:
            textColor = .primary
            font = UIFont.systemFont(ofSize: 16)
            textAlignment = .left
        case .warningTitle:
            textColor = .compatibleSecondaryLabel
            font = UIFont.systemFont(ofSize: 16, weight: .semibold)

        }
    }
    // swiftlint:enable function_body_length

}

// MARK: - Text Attributes
typealias TextAttributes = [NSAttributedString.Key: Any]

extension TextAttributes {
    static let navigationTitle = [
        NSAttributedString.Key.font: UIFont.systemFont(ofSize: 17, weight: UIFont.Weight.heavy),
        NSAttributedString.Key.foregroundColor: UIColor.compatibleLabel
    ]
}
