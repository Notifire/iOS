//
//  ChangeUserDataViewController.swift
//  Notifire
//
//  Created by David Bielik on 16/11/2020.
//  Copyright © 2020 David Bielik. All rights reserved.
//

import UIKit

class ChangePasswordViewController: VMViewController<ChangePasswordViewModel>, NotifireAlertPresenting, CenterStackViewPresenting, UserErrorResponding, APIErrorResponding, APIErrorPresenting {

    // MARK: - Properties
    lazy var textFields: [UITextField] = [
        oldPasswordTextInput.textField, newPasswordTextInput.textField, newPassword2TextInput.textField
    ]

    lazy var textFieldReturnChainer = TextFieldReturnChainer(textFields: textFields)

    // MARK: Text inputs
    lazy var oldPasswordTextInput = ValidatableTextInput.createPasswordTextInput(
        textFieldType: BottomBarTextField.self,
        newPasswordTextContentType: false,
        placeholderText: "Current password",
        viewModel: viewModel,
        bindableKeyPath: \.oldPassword
    )

    lazy var newPasswordTextInput = ValidatableTextInput.createPasswordTextInput(
        textFieldType: BottomBarTextField.self,
        newPasswordTextContentType: true,
        placeholderText: "New password",
        rules: ComponentRule.passwordRules + [
            ComponentRule(kind: .notEqualToComponent(oldPasswordTextInput), showIfBroken: true, brokenRuleDescription: "New password must be different.")
        ],
        viewModel: viewModel, bindableKeyPath: \.newPassword
    )

    lazy var newPassword2TextInput = ValidatableTextInput.createPasswordTextInput(
        textFieldType: BottomBarTextField.self,
        newPasswordTextContentType: true,
        placeholderText: "New password, again",
        rules: ComponentRule.passwordRules + [
            ComponentRule(kind: .notEqualToComponent(oldPasswordTextInput), showIfBroken: true, brokenRuleDescription: "New password must be different."),
            ComponentRule(kind: .equalToComponent(newPasswordTextInput), showIfBroken: true, brokenRuleDescription: "New passwords are different")
        ],
        viewModel: viewModel, bindableKeyPath: \.newPassword2
    )

    // MARK: NavBar buttons
    lazy var saveBarButton: UIBarButtonItem = {
        let saveButton = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(didSelectSaveNewPassword))
        saveButton.tintColor = .primary
        saveButton.isEnabled = false
        saveButton.setTitleTextAttributes([NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16, weight: .semibold)], for: .normal)
        return saveButton
    }()

    lazy var spinnerBarButton: UIBarButtonItem = {
        let style: UIActivityIndicatorView.Style
        if #available(iOS 13.0, *) {
            style = .medium
        } else {
            style = .gray
        }
        let spinner = UIActivityIndicatorView(style: style)
        spinner.hidesWhenStopped = true
        spinner.startAnimating()
        return UIBarButtonItem(customView: spinner)
    }()

    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // View
        title = viewModel.title
        view.backgroundColor = .compatibleSystemBackground

        // Navbar buttons
        updateRightBarButtonItem(animated: false)

        // Text Fields 'return'
        textFieldReturnChainer.onFinalReturn = { [weak self] in
            self?.viewModel.saveNewPassword()
        }

        setupSubviews()
        prepareViewModel()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        guard viewModel.isFirstAppearance else { return }
        viewModel.isFirstAppearance = false
        oldPasswordTextInput.textField.becomeFirstResponder()
    }

    private func setupSubviews() {
        let stackView = insertStackView(arrangedSubviews: [oldPasswordTextInput, newPasswordTextInput, newPassword2TextInput], spacing: Size.textFieldSpacing)
        stackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: Size.textFieldSpacing).isActive = true
    }

    private func prepareViewModel() {
        viewModel.createComponentValidator(with: [oldPasswordTextInput, newPasswordTextInput, newPassword2TextInput])

        viewModel.afterValidation = { [weak self] success in
            self?.saveBarButton.isEnabled = success
        }
        viewModel.loadingModel.onLoadingChange = { [weak self] loading in
            self?.textFields.forEach { $0.isEnabled = !loading }
            self?.updateRightBarButtonItem()
        }

        setViewModelOnError()
        setViewModelOnUserError()
    }

    private func updateRightBarButtonItem(animated: Bool = true) {
        if viewModel.loadingModel.isLoading {
            navigationItem.setRightBarButton(spinnerBarButton, animated: animated)
        } else {
            navigationItem.setRightBarButton(saveBarButton, animated: animated)
        }
    }

    // MARK: - Event Handlers
    @objc private func didSelectSaveNewPassword() {
        viewModel.saveNewPassword()
    }

    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return animationController(forPresented: presented)
    }
}
