//
//  UserSessionManager+CreateSession.swift
//  Notifire
//
//  Created by David Bielik on 18/11/2020.
//  Copyright © 2020 David Bielik. All rights reserved.
//

import Foundation

extension UserSessionManager {
    public static func createEmailSession(loginSuccessResponse: LoginSuccessResponse) -> UserSession {
        // userID is nil because email doesn't provide a userID token
        let providerData = AuthenticationProviderData(provider: .email, email: loginSuccessResponse.email, userID: nil)
        let session = UserSession(refreshToken: loginSuccessResponse.refreshToken, providerData: providerData)
        session.accessToken = loginSuccessResponse.accessToken
        return session
    }
}
