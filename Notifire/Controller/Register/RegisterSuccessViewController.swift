//
//  RegisterSuccessViewController.swift
//  Notifire
//
//  Created by David Bielik on 12/10/2018.
//  Copyright © 2018 David Bielik. All rights reserved.
//

import UIKit

class RegisterSuccessViewModel {

    enum ResendButtonState {
        case loading
        case finished
    }

    // MARK: - Properties
    let notifireApiManager: NotifireAPIManager
    let email: String
    var resendButtonState: ResendButtonState = .finished {
        didSet {
            onResendButtonStateChange?(resendButtonState)
        }
    }

    // MARK: Callback
    var onResendButtonStateChange: ((ResendButtonState) -> Void)?

    // MARK: - Initialization
    init(apiManager: NotifireAPIManager, email: String) {
        self.notifireApiManager = apiManager
        self.email = email
    }

    // MARK: - Methods
    func resendEmail() {
        guard case .finished = resendButtonState else { return }
        resendButtonState = .loading
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
            guard let email = self?.email else { return }
            self?.notifireApiManager.resendConfirmEmail(usernameOrEmail: email) { _ in
                self?.resendButtonState = .finished
            }
        }
    }
}

protocol RegisterSuccessViewControllerDelegate: class {
    func didFinishRegister()
    func shouldStartNewRegistration()
}

class RegisterSuccessViewController: BottomNavigatorLabelViewController, CenterStackViewPresenting {

    // MARK: - Properties
    weak var delegate: RegisterSuccessViewControllerDelegate?
    var viewModel: RegisterSuccessViewModel

    // MARK: - Initialization
    init(viewModel: RegisterSuccessViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) { fatalError() }

    // MARK: Views
    let successLabel: UILabel = {
        let label = UILabel(style: .centeredLightInformation)
        label.text = "Confirm your account with the link we've sent to your email inbox!"
        return label
    }()

    lazy var resendConfirmationEmailButton: NotifireButton = {
        let button = NotifireButton()
        button.setTitle("Resend confirmation email", for: .normal)
        button.onProperTap = { [unowned self] in
            self.viewModel.resendEmail()
        }
        return button
    }()

    lazy var newRegistrationButton: ActionButton = {
        let button = ActionButton(type: .system)
        button.setTitle("New registration", for: .normal)
        button.onProperTap = { [unowned self] in
            self.delegate?.shouldStartNewRegistration()
        }
        return button
    }()

    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // navigation bar
        title = "Success!"
        navigationItem.setHidesBackButton(true, animated: false)

        // buttons
        tappableLabel.onHypertextTapped = { [unowned self] in
            self.delegate?.didFinishRegister()
        }
        let hyperText = "Sign in"
        let text = "Already using Notifire? \(hyperText)."
        tappableLabel.set(hypertext: hyperText, in: text)

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
