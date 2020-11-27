//
//  Config+TrustKit.swift
//  Notifire
//
//  Created by David Bielik on 27/11/2020.
//  Copyright © 2020 David Bielik. All rights reserved.
//

import Foundation
import TrustKit

// MARK: - TrustKit
extension Config {

    static let trustKitConfig: [String: Any] = [
        kTSKSwizzleNetworkDelegates: false,
        kTSKPinnedDomains: [
            apiUrlString: [
                kTSKPublicKeyHashes: [
                    // - Important:
                    // Always use at least 2 public keys otherwise a runtime exception will be thrown in didFinishLaunching.
                    apiPublicKey2020Hash,
                    "BBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB="
                ],
                kTSKDisableDefaultReportUri: true
            ]
        ]
    ]
}
