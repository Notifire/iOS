//
//  ChangeEmailViewController.swift
//  Notifire
//
//  Created by David Bielik on 17/11/2020.
//  Copyright © 2020 David Bielik. All rights reserved.
//

import UIKit

class ChangeEmailViewController: VMViewController<ChangeEmailViewModel>, CenterStackViewPresenting, NotifireAlertPresenting, APIErrorResponding, APIErrorPresenting {

    // MARK: - Properties
    lazy var textFieldReturnChainer = TextFieldReturnChainer(textFields: [emailTextInput.textField], setLastReturnKeyTypeToDone: true) { [weak self] in
        self?.viewModel.sendChangeEmail()
    }

    // MARK: UI
    lazy var emailTextInput: ValidatableTextInput = {
        let emailTextField = BottomBarTextField()
        emailTextField.setPlaceholder(text: "Enter a new email address")
        emailTextField.keyboardType = .emailAddress
        let input = ValidatableTextInput(textField: emailTextField)
        input.rules = ComponentRule.createEmailRules + [
            ComponentRule(kind: .notEqualToString(viewModel.userSession.email), showIfBroken: true, brokenRuleDescription: "Please enter a different email than your current one")
        ]
        input.validatingViewModelBinder = ValidatingViewModelBinder(viewModel: viewModel, for: \.email)
        return input
    }()

    lazy var sendEmailChangeLinkButton: NotifireButton = {
        let button = NotifireButton()
        button.isEnabled = false
        button.setTitle("Send confirmation link", for: .normal)
        button.onProperTap = { [unowned self] _ in
            self.viewModel.sendChangeEmail()
        }
        return button
    }()

    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        title = viewModel.title
        view.backgroundColor = .compatibleSystemBackground

        setupSubviews()
        prepareViewModel()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        guard viewModel.isFirstAppearance else { return }
        viewModel.isFirstAppearance = false
        emailTextInput.textField.becomeFirstResponder()
    }

    // MARK: - Private
    private func setupSubviews() {
        let stackView = insertStackView(arrangedSubviews: [emailTextInput, sendEmailChangeLinkButton])
        stackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: Size.componentSpacing).isActive = true
    }

    private func prepareViewModel() {
        viewModel.createComponentValidator(with: [emailTextInput])

        viewModel.afterValidation = { [weak self] success in
            self?.sendEmailChangeLinkButton.isEnabled = success
        }
        viewModel.loadingModel.onLoadingChange = { [weak self] loading in
            self?.emailTextInput.textField.isEnabled = !loading
            self?.sendEmailChangeLinkButton.changeLoading(to: loading)
        }

        viewModel.onSendChangeEmailResult = { [weak self] success in
            self?.presentChangeEmailResult(success)
        }

        setViewModelOnError()
    }

    private func presentChangeEmailResult(_ success: Bool) {
        let alertTitle: String?
        let alertText: String?
        let alertStyle: NotifireAlertViewController.AlertStyle?
        if success {
            alertTitle = "Check your inbox!"
            alertText = "We have sent an email to your current address (\(viewModel.userSession.email)). Please click the attached link to confirm the email change."
            alertStyle = nil
        } else {
            alertTitle = nil
            alertText = "Looks like you have entered an invalid email. Please try again with another one."
            alertStyle = .fail
        }
        let alertVC = NotifireAlertViewController(alertTitle: alertTitle, alertText: alertText, alertStyle: alertStyle)
        alertVC.add(action: NotifireAlertAction(title: "OK", style: .positive, handler: { _ in
            alertVC.dismiss(animated: true, completion: nil)

        }))
        emailTextInput.textField.text = ""
        present(alert: alertVC, animated: true, completion: nil)
    }
}
