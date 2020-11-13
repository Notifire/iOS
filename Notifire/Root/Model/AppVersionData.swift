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

    /// Compares two version strings while ignoring the PATCH value.
    /// For more info on the versioning check: https://semver.org/
    ///
    /// - Parameters:
    ///     -   version1: Should be the latest version of the app if you want to compare the result to .orderedDescending and then proceed with an update.
    ///     -   version2: Should be the current version of the app.
    ///
    /// The versioning system example:
    /// ```
    ///     <MAJOR>.<MINOR>.<PATCH>
    ///        1   .   0   .   1
    /// ```
    /// Function result example:
    /// ```
    ///     let result = compareVersionsWithoutPatch(
    ///         version1: "1.0.1",
    ///         version2: "1.0.5"
    ///     )
    ///
    ///     print(result)  // .orderedSame even though the patch value is higher in version2
    /// ```
    static func compareVersionsIgnoringPatch(version1: String, version2: String) -> ComparisonResult {
        let removePatchClosure: ((String) -> String) = { version in
            switch version.components(separatedBy: ".").count {
            case 3:
                return version.split(separator: ".").dropLast().joined(separator: ".")
            default:
                return version
            }
        }

        let version1WithoutPatch = removePatchClosure(version1)
        let version2WithoutPatch = removePatchClosure(version2)

        return version1WithoutPatch.compare(version2WithoutPatch, options: [.numeric])
    }
}
