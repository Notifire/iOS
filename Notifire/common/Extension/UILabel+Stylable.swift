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

    case heavyTitle
    case semiboldCellTitle
    case dimmedInformation
    case cellInformation
    case cellSubtitle
    case informationHeader
    case secureInformation
    case centeredLightInformation
    case emoji
    case negativeMedium
    case notifirePositive
    case alertTitle
    case alertInformation
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
            textColor = .customLabel
            font = UIFont.systemFont(ofSize: 15)
        case .secondary:
            textColor = .customSecondaryLabel
            font = UIFont.systemFont(ofSize: 14)
        case .largeTitle:
            textColor = .customLabel
            font = UIFont.systemFont(ofSize: 28, weight: .bold)
        case .title:
            textColor = .customLabel
            font = UIFont.systemFont(ofSize: 20, weight: .bold)
        case .negative:
            textColor = UIColor.red.withAlphaComponent(0.9)
            font = UIFont.systemFont(ofSize: 14)
            textAlignment = .left

        case .heavyTitle:
            textColor = .black
            font = UIFont.systemFont(ofSize: 17, weight: .heavy)
        case .semiboldCellTitle:
            textColor = .black
            font = UIFont.systemFont(ofSize: 17, weight: .semibold)
        case .dimmedInformation:
            textColor = UIColor.black.withAlphaComponent(0.8)
            font = UIFont.systemFont(ofSize: 17)
        case .cellInformation:
            textColor = .black
            font = UIFont.systemFont(ofSize: 15)
        case .cellSubtitle:
            textColor = UIColor.black.withAlphaComponent(0.5)
            font = UIFont.systemFont(ofSize: 14)
        case .informationHeader:
            textColor = .black
            font = UIFont.systemFont(ofSize: 16)
        case .secureInformation:
            textColor = UIColor.black.withAlphaComponent(0.7)
            font = UIFont.systemFont(ofSize: 14)
            textAlignment = .justified
            numberOfLines = 0
        case .centeredLightInformation:
            font = UIFont.systemFont(ofSize: 12, weight: UIFont.Weight.light)
            textAlignment = .center
        case .emoji:
            font = UIFont.systemFont(ofSize: 24)
            textAlignment = .center
        case .negativeMedium:
            textColor = UIColor.red.withAlphaComponent(0.9)
            font = UIFont.systemFont(ofSize: 16, weight: .medium)
            textAlignment = .center
        case .notifirePositive:
            textColor = .notifireMainColor
            font = UIFont.systemFont(ofSize: 16)
            textAlignment = .left
        case .alertTitle:
            textColor = .black
            font = UIFont.systemFont(ofSize: 20, weight: .semibold)
            numberOfLines = 2
            textAlignment = .center
        case .alertInformation:
            textColor = .black
            numberOfLines = 0
            font = UIFont.systemFont(ofSize: 15, weight: .medium)
            textAlignment = .center
        }
    }
    // swiftlint:enable function_body_length

}