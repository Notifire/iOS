//
//  AppVersionData.swift
//  Notifire
//
//  Created by David Bielik on 07/11/2020.
//  Copyright © 2020 David Bielik. All rights reserved.
//

import Foundation

/// The application version data.
struct AppVersionData: Codable {
    let appVersionResponse: AppVersionResponse

    static func compareVersions(version1: String, version2: String) -> ComparisonResult {
        let removeMinorVersionClosure: ((String) -> String) = { version in
            switch version.components(separatedBy: ".").count {
            case 3:
                return version.split(separator: ".").dropLast().joined(separator: ".")
            default:
                return version
            }
        }

        let version1WithoutMinor = removeMinorVersionClosure(version1)
        let version2WithoutMinor = removeMinorVersionClosure(version2)

        return version1WithoutMinor.compare(version2WithoutMinor, options: [.numeric])
    }
}
