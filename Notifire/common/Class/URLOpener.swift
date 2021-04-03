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

    static func open(url: URL) {
        guard let safeURL = url.safeToOpenWithSafari else { return }
        UIApplication.shared.open(safeURL, options: [:], completionHandler: nil)
    }

    static func open(urlString: String) {
        guard let url = URL(string: urlString) else { return }
        open(url: url)
    }
}

extension URL {

    /// Return a URL that contains "http" as the scheme if there is no scheme.
    var safeToOpenWithSafari: URL? {
        guard var components = URLComponents(url: self, resolvingAgainstBaseURL: false) else { return nil }
        if components.scheme == nil {
            components.scheme = "http"
        }
        return components.url
    }
}
