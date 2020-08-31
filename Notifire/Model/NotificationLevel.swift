//
//  NotificationLevel.swift
//  Notifire
//
//  Created by David Bielik on 14/12/2018.
//  Copyright © 2018 David Bielik. All rights reserved.
//

import Foundation

enum NotificationLevel: String, CustomStringConvertible, Decodable {
    case info = "info"
    case warning = "warning"
    case error = "error"
    
    var emoji: String {
        switch self {
        case .info: return "ℹ️"
        case .warning: return "⚠️"
        case .error: return "❗️"
        }
    }
    
    var description: String {
        switch self {
        case .info: return "Information"
        case .warning: return "Warning"
        case .error: return "Error"
        }
    }
}
