//
//  LaunchArgument.swift
//  Notifire
//
//  Created by David Bielik on 13/09/2020.
//  Copyright © 2020 David Bielik. All rights reserved.
//

import Foundation

enum LaunchArgument: String, CaseIterable {
    case resetKeychainData
    case turnOffAnimations

    static func append(_ arg: LaunchArgument, to arguments: inout [String]) {
        arguments.append(arg.rawValue)
    }
}
