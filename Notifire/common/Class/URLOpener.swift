//
//  URLOpener.swift
//  Notifire
//
//  Created by David Bielik on 22/11/2020.
//  Copyright © 2020 David Bielik. All rights reserved.
//

import UIKit

class URLOpener {

    /// Open the Settings.app notification settings for current Bundle identifier
    static func goToNotificationSettings() {
        guard
            let appSettings = URL(string: UIApplication.openSettingsURLString + Config.bundleID),
            UIApplication.shared.canOpenURL(appSettings)
        else { return }
            UIApplication.shared.open(appSettings)
    }
}
