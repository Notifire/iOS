//
//  LaunchArgumentsHandler.swift
//  Notifire
//
//  Created by David Bielik on 13/09/2020.
//  Copyright © 2020 David Bielik. All rights reserved.
//

import UIKit
import RealmSwift

struct LaunchArgumentsHandler {

    // MARK: - Methods
    /// Handles all launch arguments that have been passed to the application
    public func handleLaunchArgumentsIfNeeded() {
        #if DEBUG
        handleLaunchArguments()
        #endif
    }

    private func handleLaunchArguments() {
        let launchArguments = ProcessInfo.processInfo.arguments

        for argument in LaunchArgument.allCases where launchArguments.contains(argument.rawValue) {
            handleLaunch(argument: argument)
        }
    }

    private func handleLaunch(argument: LaunchArgument) {
        switch argument {
        case .resetKeychainData:
            let secItemClasses = [kSecClassGenericPassword, kSecClassInternetPassword, kSecClassCertificate, kSecClassKey, kSecClassIdentity]
            for itemClass in secItemClasses {
                let spec: NSDictionary = [kSecClass: itemClass]
                SecItemDelete(spec)
            }
        case .resetUserDefaultsData:
            UserDefaults.standard.removePersistentDomain(forName: Config.bundleID)
            UserDefaults.standard.synchronize()
        case .resetRealmData:
            try? FileManager.default.removeItem(at: RealmManager.realmSharedDatabaseDirectoryURL)
        case .turnOffAnimations:
            UIView.setAnimationsEnabled(false)
        }
    }
}
