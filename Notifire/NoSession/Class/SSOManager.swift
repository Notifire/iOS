//
//  SSOManager.swift
//  Notifire
//
//  Created by David Bielik on 03/09/2020.
//  Copyright © 2020 David Bielik. All rights reserved.
//

import Foundation
import GoogleSignIn

class SSOManager: NSObject, GIDSignInDelegate {

    // MARK: - Properties
    /// The current authentication attempt. Nil if there is no attempt currently in progress.
    var ssoAuthenticationAttempt: SSOAuthenticationAttempt?

    weak var delegate: SSOManagerDelegate?

    // MARK: - Initialization
    override init() {

        super.init()
        // Google
        // Initialize sign-in
        GIDSignIn.sharedInstance()?.clientID = "117989498999-jtrgruedprrjdhji1uu4kv0qur1s5lfd.apps.googleusercontent.com"
        GIDSignIn.sharedInstance()?.delegate = self

    }

    func signIn(with provider: SSOAuthenticationProvider) {
        // Create new authentication attempt
        let newAuthAttempt = SSOAuthenticationAttempt(provider: provider)
        // Verify, that we are not already authenticating
        if let currentAuthenticationAttempt = ssoAuthenticationAttempt {
            newAuthAttempt.state = .error(.authenticationAlreadyInProgress(currentAuthenticationAttempt))
            finishAuthenticationAttempt()
        }
        ssoAuthenticationAttempt = newAuthAttempt
        delegate?.willStart(authenticationAttempt: newAuthAttempt)
        // Start the attempt
        switch provider {
        case .google:
            GIDSignIn.sharedInstance()?.signIn()
        case .apple, .github, .twitter:
            // FIXME: implement the above providers sign in
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
                self?.finishAuthenticationAttempt()
            }
            break
        }
        delegate?.didStart(authenticationAttempt: newAuthAttempt)
    }

    private func finishAuthenticationAttempt() {
        guard let currentAuthAttempt = ssoAuthenticationAttempt else { return }
        ssoAuthenticationAttempt = nil
        delegate?.didFinish(authenticationAttempt: currentAuthAttempt)
    }

    // MARK: - Google
    // MARK: GIDSignInDelegate
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        // Check if the current authentication attempt is for Google
        guard let currentAuthAttempt = ssoAuthenticationAttempt else { return }
        // We finish the authentication attempt in any case.
        defer { finishAuthenticationAttempt() }
        // Check if the provider is google
        guard currentAuthAttempt.provider == .google else {
            currentAuthAttempt.state = .error(.unknown)
            return
        }

        if let error = error {
            if (error as NSError).code == GIDSignInErrorCode.hasNoAuthInKeychain.rawValue {
                //print("The user has not signed in before or they have since signed out.")
                currentAuthAttempt.state = .error(.userHasNotSignedIn)
            } else if (error as NSError).code == GIDSignInErrorCode.canceled.rawValue {
                currentAuthAttempt.state = .error(.userCancelled)
            } else {
                currentAuthAttempt.state = .error(.unknown)
            }
        } else {
            // Perform any operations on signed in user here.
            //let userId = user.userID                  // For client-side use only!
            let maybeIdToken = user.authentication.idToken // Safe to send to the server
            //let fullName = user.profile.name
            //let givenName = user.profile.givenName
            //let familyName = user.profile.familyName
            //let email = user.profile.email

            guard let idToken = maybeIdToken else {
                currentAuthAttempt.state = .error(.unableToRetrieveAccessToken)
                return
            }
            currentAuthAttempt.state = .finished(accessToken: idToken)
        }
    }

    func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!, withError error: Error!) {

    }
}
