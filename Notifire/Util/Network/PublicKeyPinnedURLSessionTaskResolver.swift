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

    let trustKit: TrustKit

    override init() {
        self.trustKit = TrustKit.init(configuration: Config.trustKitConfig)
        super.init()
        TrustKit.setLoggerBlock { str in
            Logger.logNetwork(.info, "TrustKit \(str)")
        }
    }

    deinit {

    }

    // MARK: - URLSessionTaskDelegate
    func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
//        if !trustKit.pinningValidator.handle(challenge, completionHandler: completionHandler) {
//            completionHandler(.performDefaultHandling, nil)
//        }
        completionHandler(.useCredential, URLCredential(trust: challenge.protectionSpace.serverTrust!))
    }
}
