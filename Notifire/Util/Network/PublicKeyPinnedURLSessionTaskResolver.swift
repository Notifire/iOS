//
//  PublicKeyPinnedURLSessionTaskResolver.swift
//  Notifire
//
//  Created by David Bielik on 27/11/2020.
//  Copyright © 2020 David Bielik. All rights reserved.
//

import Foundation
import TrustKit

class PublicKeyPinnedURLSessionTaskResolver: NSObject, URLSessionTaskDelegate {

    static let trustKit: TrustKit = {
        let trustKit = TrustKit.init(configuration: Config.trustKitConfig)
        TrustKit.setLoggerBlock { str in
            Logger.logNetwork(.info, "TrustKit \(str)")
        }
        return trustKit
    }()

    // MARK: - URLSessionTaskDelegate
    func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        if !Self.trustKit.pinningValidator.handle(challenge, completionHandler: completionHandler) {
            completionHandler(.performDefaultHandling, nil)
        }
    }
}
