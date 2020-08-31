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
    static let componentWidthRelativeToScreenWidth: CGFloat = 0.8
    
    static let iconSize: CGFloat = 32
    static let standardMargin: CGFloat = 16
    static let extendedMargin: CGFloat = 18
    
    struct Image {
        static let smallService: CGFloat = 36
        static let mediumService: CGFloat = 50
        static let normalService: CGFloat = 80
        static let emoji: CGFloat = 40
        static let tabBarIcon: CGFloat = 30
        static let unreadNotificationAlert: CGFloat = 8
        static let indicator: CGFloat = 16
    }
    
    struct Cell {
        static let height: CGFloat = 48
        static let narrowSideMargin: CGFloat = 12
        static let sideMargin: CGFloat = 16
        static let extendedSideMargin: CGFloat = 18
        static let wideSideMargin: CGFloat = 40
    }
    
    struct Navigator {
        static let height: CGFloat = 48
        static let separatorHeight: CGFloat = 1
    }
    
    struct Tab {
        static let height: CGFloat = 50
    }
}
