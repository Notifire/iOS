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
        switch self {
        case .notifications: return #imageLiteral(resourceName: "outline_notifications_black_48pt")
        case .services: return #imageLiteral(resourceName: "outline_dashboard_black_48pt")
        case .settings: return #imageLiteral(resourceName: "outline_settings_black_48pt")
        }
    }
    
    var highlightedImage: UIImage {
        switch self {
        case .notifications: return #imageLiteral(resourceName: "baseline_notifications_black_48pt")
        case .services: return #imageLiteral(resourceName: "baseline_dashboard_black_48pt")
        case .settings: return #imageLiteral(resourceName: "baseline_settings_black_48pt")
        }
    }
}
