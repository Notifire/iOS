//
//  LaunchArgumentsHandler.swift
//  Notifire
//
//  Created by David Bielik on 13/09/2020.
//  Copyright © 2020 David Bielik. All rights reserved.
//

import UIKit

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
            UserSessionManager().removePreviousSessionIfNeeded()
        case .turnOffAnimations:
            UIView.setAnimationsEnabled(false)
        }
    }
}
