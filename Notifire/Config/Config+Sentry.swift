//
//  Config+Sentry.swift
//  Notifire
//
//  Created by David Bielik on 27/11/2020.
//  Copyright © 2020 David Bielik. All rights reserved.
//

import Foundation
import Sentry

// MARK: - Sentry
extension Config {
    static func initSentry() {
        SentrySDK.start { options in
            options.dsn = Config.sentryDsn
            options.debug = true
            options.environment = Config.bundleID
        }
    }
}
