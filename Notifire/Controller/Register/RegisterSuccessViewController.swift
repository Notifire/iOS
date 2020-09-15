//
//  RegisterSuccessViewController.swift
//  Notifire
//
//  Created by David Bielik on 12/10/2018.
//  Copyright © 2018 David Bielik. All rights reserved.
//

import UIKit

class RegisterSuccessViewController: VMViewController<RegisterSuccessViewModel>, BottomNavigatorLabelContaining, CenterStackViewPresenting {

    // MARK: - Properties
    weak var delegate: RegisterSuccessViewControllerDelegate?

    // MARK: Views
    let successLabel: UILabel = {
        let label = UILabel(style: .centeredLightInformation)
        label.text = "Confirm your account with the link we've sent to your email inbox!"
        return label
    }()

    lazy var resendConfirmationEmailButton: NotifireButton = {
        let button = NotifireButton()
        button.setTitle("Resend confirmation email", for: .normal)
        button.onProperTap = { [unowned self] _ in
            self.viewModel.resendEmail()
        }
        return button
    }()

    lazy var newRegistrationButton: ActionButton = {
        let button = ActionButton(type: .system)
        button.setTitle("Register a new account", for: .normal)
        button.onProperTap = { [unowned self] _ in
            self.delegate?.shouldStartNewRegistration()
        }
        return button
    }()

    // MARK: BottomNavigatorLabelContaining
    lazy var bottomNavigator: UIView = defaultBottomNavigatorView()
    lazy var bottomNavigatorLabel: UILabel = {
        let label = TappableLabel()
        label.set(style: .primary)
        let hyperText = "Sign in"
        let text = "Already using Notifire? \(hyperText)."
        label.set(hypertext: hyperText, in: text)
        label.onHypertextTapped = { [weak self] in
            self?.delegate?.didFinishRegister()
        }
        return label
    }()

    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .compatibleSystemBackground

        // navigation bar
        title = "Success!"
        navigationItem.setHidesBackButton(true, animated: false)

        // viewModel
        viewModel.onResendButtonStateChange = { newState in
            switch newState {
            case .finished:
                self.resendConfirmationEmailButton.stopLoading()
            case .loading:
                self.resendConfirmationEmailButton.startLoading()
            }
        }

        layout()
    }

    // MARK: - Private
    private func layout() {
        let stackView = insertStackView(arrangedSubviews: [successLabel, ChoiceSeparatorView(), resendConfirmationEmailButton], spacing: Size.componentSpacing)
        stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true

        view.add(subview: newRegistrationButton)
        newRegistrationButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        newRegistrationButton.bottomAnchor.constraint(equalTo: bottomNavigator.topAnchor, constant: -Size.componentSpacing).isActive = true
    }
}
