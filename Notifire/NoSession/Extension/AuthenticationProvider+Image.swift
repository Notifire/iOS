//
//  AuthenticationProvider+Image.swift
//  Notifire
//
//  Created by David Bielik on 07/09/2020.
//  Copyright © 2020 David Bielik. All rights reserved.
//

import UIKit

extension AuthenticationProvider {
    /// UIImage used for this provider
    /// - Note:
    ///     - Have to keep this variable in an extension because of NotificationServiceExtension target membership dependencies
    var providerImage: UIImage {
        switch self {
        case .sso(let provider): return provider.image
        case .email:
            let image = UIImage(imageLiteralResourceName: "envelope_symbol")
            return image.withRenderingMode(.alwaysTemplate)
        }
    }
}
