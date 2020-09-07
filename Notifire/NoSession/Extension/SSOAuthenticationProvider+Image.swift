//
//  SSOAuthenticationProvider+Image.swift
//  Notifire
//
//  Created by David Bielik on 07/09/2020.
//  Copyright © 2020 David Bielik. All rights reserved.
//

import UIKit

extension SSOAuthenticationProvider {
    /// The image (icon) associated with this SSO provider
    /// - Note:
    ///     - Have to keep this variable in an extension because of NotificationServiceExtension target membership dependencies
    var image: UIImage {
        switch self {
        case .apple: return #imageLiteral(resourceName: "default_service_image").resized(to: CGSize(equal: 18))
        case .github: return #imageLiteral(resourceName: "github_icon").resized(to: CGSize(equal: 18)).withRenderingMode(.alwaysTemplate)
        case .google: return #imageLiteral(resourceName: "google_icon").resized(to: CGSize(equal: 17))
        case .twitter: return #imageLiteral(resourceName: "twitter_icon").resized(to: CGSize(equal: 26))
        }
    }
}
