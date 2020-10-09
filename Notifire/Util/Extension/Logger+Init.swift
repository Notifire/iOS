//
//  Logger+Init.swift
//  Notifire
//
//  Created by David Bielik on 24/09/2020.
//  Copyright © 2020 David Bielik. All rights reserved.
//

import Foundation
import os.log

class Logger {

    enum Category: String {
        case main
        case network
    }

    static let shared = Logger()

    private let underlyingMainLogger = OSLog(subsystem: Config.bundleID, category: .main)
    private let underlyingNetworkLogger = OSLog(subsystem: Config.bundleID, category: .network)

    func log(_ level: OSLogType = .debug, _ msg: String, _ logger: OSLog) {
        os_log("%{public}s", log: logger, type: level, msg)
    }

    static func log(_ level: OSLogType = .debug, _ msg: String) {
        Logger.shared.log(level, msg, Logger.shared.underlyingMainLogger)
    }

    static func logNetwork(_ level: OSLogType = .debug, _ msg: String) {
        Logger.shared.log(level, msg, Logger.shared.underlyingNetworkLogger)
    }
}

extension OSLog {
    convenience init(subsystem: String, category: Logger.Category) {
        self.init(subsystem: subsystem, category: category.rawValue)
    }
}
