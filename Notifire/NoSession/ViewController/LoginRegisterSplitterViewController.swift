//
//  LoginRegisterSplitterViewController.swift
//  Notifire
//
//  Created by David Bielik on 02/09/2020.
//  Copyright © 2020 David Bielik. All rights reserved.
//

import UIKit
import GoogleSignIn

/**
This ViewController allows the user to choose between signing up and logging into the app.

# Displayed data:
- Sign in with email
- Sign in with Apple
- Sign in with Google
- Sign in with GitHub
- Sign in with Twitter
- Already using Notifire? Login here instead.
 */
class LoginRegisterSplitterViewController: VMViewController<LoginRegisterSplitterViewModel>, BottomNavigatorLabelContaining, UserErrorFailableResponding, APIFailableResponding, APIFailableDisplaying {

    // MARK: - Properties
    weak var delegate: LoginRegisterSplitterViewControllerDelegate?

    // MARK: UI
    /// The View containing a stackview of sign in UIButtons
    let authProvidersView = AuthenticationProvidersView(
        viewModel: AuthenticationProvidersViewModel(providers: AuthenticationProvider.providers)
    )

    let headerLabel: UILabel = {
        let label = UILabel(style: .largeTitle)
        label.text = "Let's notify. From anywhere, anytime."
        label.textAlignment = .center
        return label
    }()

    let headerSecondaryLabel: UILabel = {
        let label = UILabel(style: .secondary)
        // TODO: Add ToS
        label.text = "But first, you need to register an account. By registering you also agree to our Terms of Service."
        label.textAlignment = .center
        return label
    }()

    // MARK: BottomNavigatorLabelContaining
    lazy var bottomNavigator: UIView = defaultBottomNavigatorView()
    lazy var bottomNavigatorLabel: UILabel = {
        let label = TappableLabel()
        label.set(style: .primary)
        let hyperText = "Sign up"
        label.set(hypertext: hyperText, in: "Don't have an account yet? Sign up instead.")
        return label
    }()

    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        // ViewModel Settings 
        viewModel.authenticationProvidersVM = authProvidersView.viewModel
        authProvidersView.viewModel.ssoManager.delegate = viewModel

        viewModel.onLogin = { [weak self] session in
            self?.delegate?.didCreate(session: session)
        }

        setViewModelOnError()
        setViewModelOnUserError()

        // View Settings
        view.backgroundColor = .compatibleBackgroundAccent

        setupSubviews()

        // Set the action for the Email button
        if let emailButton = authProvidersView.emailButtonControl as? SignInButton {
            emailButton.onProperTap = { [unowned self] _ in
                self.delegate?.shouldStartLoginFlow()
            }
        }

        // SSO
        GIDSignIn.sharedInstance()?.presentingViewController = self
    }

    private func setupSubviews() {
        addBottomNavigator()
        addBottomNavigatorLabel()

        view.add(subview: authProvidersView)
        authProvidersView.bottomAnchor.constraint(equalTo: bottomNavigator.topAnchor, constant: -Size.componentSpacing).isActive = true
        authProvidersView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        authProvidersView.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true

        view.add(subview: headerLabel)
        headerLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        headerLabel.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: Size.componentWidthRelativeToScreenWidth).isActive = true
        headerLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: Size.Navigator.height * 2).isActive = true

        view.add(subview: headerSecondaryLabel)
        headerSecondaryLabel.centerXAnchor.constraint(equalTo: headerLabel.centerXAnchor).isActive = true
        headerSecondaryLabel.widthAnchor.constraint(equalTo: headerLabel.widthAnchor).isActive = true
        headerSecondaryLabel.topAnchor.constraint(equalTo: headerLabel.bottomAnchor, constant: Size.componentSpacing).isActive = true
    }
}
