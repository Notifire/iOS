//
//  Size.swift
//  Notifire
//
//  Created by David Bielik on 27/08/2018.
//  Copyright © 2018 David Bielik. All rights reserved.
//

import UIKit

struct Size {
    static let textFieldSpacing: CGFloat = 14
    static let componentSpacing: CGFloat = textFieldSpacing * 2.5
    static let componentHeight: CGFloat = 44
    static let footerHeight: CGFloat = 60
    static let componentWidthRelativeToScreenWidth: CGFloat = 0.8

    static let iconSize: CGFloat = 32
    static let smallestMargin: CGFloat = 6
    static let smallMargin: CGFloat = 8
    static let standardMargin: CGFloat = 16
    static let extendedMargin: CGFloat = 18
    static let doubleMargin: CGFloat = 32

    struct Image {
        static let settingsImage: CGFloat = 29
        static let tinyService: CGFloat = 16
        static let smallService: CGFloat = 36
        static let mediumService: CGFloat = 50
        static let normalService: CGFloat = 80
        static let largeService: CGFloat = 128
        static let extraLargeService: CGFloat = 172
        static let alertSuccessFailImage: CGFloat = 80
        static let tabBarIcon: CGFloat = 24
        static let symbol: CGFloat = 24
        static let unreadNotificationAlert: CGFloat = 8
        static let indicator: CGFloat = 16
    }

    struct Cell {
        static let height: CGFloat = 44
        static let insetGroupedHeight: CGFloat = 52
        static let heightExtended: CGFloat = 60
        static let narrowSideMargin: CGFloat = 12
        static let sideMargin: CGFloat = 16
        static let extendedSideMargin: CGFloat = 18
        static let wideSideMargin: CGFloat = 40
    }

    struct Navigator {
        static let smallSymbolSize: CGSize = CGSize(equal: 14)
        static let symbolSize: CGSize = CGSize(equal: Image.symbol)
        static let height: CGFloat = 48
        static let separatorHeight: CGFloat = 1
    }

    struct Tab {
        static let height: CGFloat = 50
    }

    struct Font {
        static let placeholder: CGFloat = 12
        static let `default`: CGFloat = 14
        static let action: CGFloat = 16
    }
}
