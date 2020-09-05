//
//  SSOManagerDelegate.swift
//  Notifire
//
//  Created by David Bielik on 03/09/2020.
//  Copyright © 2020 David Bielik. All rights reserved.
//

import Foundation

protocol SSOManagerDelegate: class {
    func willStart(authenticationAttempt: SSOAuthenticationAttempt)
    func didStart(authenticationAttempt: SSOAuthenticationAttempt)
    func didFinish(authenticationAttempt: SSOAuthenticationAttempt)
}
