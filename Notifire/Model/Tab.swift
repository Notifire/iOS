//
//  Tab.swift
//  Notifire
//
//  Created by David Bielik on 12/10/2018.
//  Copyright © 2018 David Bielik. All rights reserved.
//

import UIKit

enum Tab: CaseIterable {
    case services
    case notifications
    case settings

    var image: UIImage {
        guard #available(iOS 13, *) else {
            switch self {
            case .notifications: return #imageLiteral(resourceName: "outline_notifications_black_48pt")
            case .services: return #imageLiteral(resourceName: "outline_dashboard_black_48pt")
            case .settings: return #imageLiteral(resourceName: "outline_settings_black_48pt")
            }
        }
        switch self {
        case .services: return createTabBarUIImage(systemName: "cube.box")
        case .notifications: return createTabBarUIImage(systemName: "bell")
        case .settings: return createTabBarUIImage(systemName: "gear")
        }
    }

    var highlightedImage: UIImage {
        guard #available(iOS 13, *) else {
            switch self {
            case .notifications: return #imageLiteral(resourceName: "baseline_notifications_black_48pt")
            case .services: return #imageLiteral(resourceName: "baseline_dashboard_black_48pt")
            case .settings: return #imageLiteral(resourceName: "baseline_settings_black_48pt")
            }
        }
        switch self {
        case .services: return createTabBarUIImage(systemName: "cube.box.fill")
        case .notifications: return createTabBarUIImage(systemName: "bell.fill")
        case .settings: return createTabBarUIImage(systemName: "gear")
        }
    }

    @available(iOS 13, *)
    private func createTabBarUIImage(systemName: String) -> UIImage {
        let configuration = UIImage.SymbolConfiguration(pointSize: Size.Image.tabBarIcon)
        return UIImage(systemName: systemName, withConfiguration: configuration) ?? UIImage()
    }
}

typealias Tabs = [Tab]
