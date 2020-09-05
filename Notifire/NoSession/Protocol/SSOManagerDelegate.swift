//
//  SSOManagerDelegate.swift
//  Notifire
//
//  Created by David Bielik on 03/09/2020.
//  Copyright © 2020 David Bielik. All rights reserved.
//

import Foundation

/// The Delegate Class for SSOManager
protocol SSOManagerDelegate: class {

    /// Called right when the SSOAuthenticationAttempt is instantiated.
    func willStart(authenticationAttempt: SSOAuthenticationAttempt)

    /// Called when the SSOAuthenticationAttempt is started successfully.
    func didStart(authenticationAttempt: SSOAuthenticationAttempt)

    /// Called whenever the authentication attempt is finished.
    /// - Note:
    ///     - To check if the attempt finished successfully read the `SSOAuthenticationAttempt.state` variable.
    func didFinish(authenticationAttempt: SSOAuthenticationAttempt)
}
