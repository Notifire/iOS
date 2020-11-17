//
//  ServiceCreationViewController.swift
//  Notifire
//
//  Created by David Bielik on 09/11/2018.
//  Copyright © 2018 David Bielik. All rights reserved.
//

import UIKit

protocol ServiceCreationDelegate: class {
    func didCancelCreation()
    func didCreate(service: Service)
}

class ServiceCreationViewController: UIViewController, CenterStackViewPresenting, APIErrorResponding, APIErrorPresenting, KeyboardObserving {

    // MARK: - Properties
    weak var delegate: ServiceCreationDelegate?
    var viewModel: ServiceCreationViewModel

    // MARK: KeyboardObserving
    var stackViewCenterCollapsedConstraint: NSLayoutConstraint!
    var stackViewCenterNormalConstraint: NSLayoutConstraint!
    let keyboardObserverHandler = KeyboardObserverHandler()

    // MARK: Views
    let newServiceTextField: BorderedTextField = {
        let textField = BorderedTextField()
        textField.setPlaceholder(text: "Enter the service name")
        return textField
    }()

    lazy var createServiceButton: NotifireButton = {
        let button = NotifireButton()
        button.isEnabled = false
        button.setTitle("Create", for: .normal)
        button.onProperTap = { [unowned self] _ in
            self.viewModel.createService()
        }
        return button
    }()

    lazy var cancelButton: ActionButton = {
        let button = ActionButton(type: .system)
        button.setTitle("Cancel", for: .normal)
        button.onProperTap = { [unowned self] _ in
            self.delegate?.didCancelCreation()
        }
        return button
    }()

    lazy var newServiceTextInput: ValidatableTextInput = {
        let input = ValidatableTextInput(textField: newServiceTextField)
        input.rules = [
            ComponentRule(kind: .minimum(length: 1), showIfBroken: false),
            ComponentRule(kind: .maximum(length: Settings.Text.maximumUsernameLength), showIfBroken: true)
        ]
        return input
    }()

    lazy var stackView = insertStackView(arrangedSubviews: [newServiceTextInput, createServiceButton, ChoiceSeparatorView(), cancelButton], spacing: Size.componentSpacing)

    // MARK: - Initialization
    init(viewModel: ServiceCreationViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) { fatalError() }

    deinit {
        stopObservingNotifications()
    }

    // MARK: - View lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .compatibleSystemBackground
        addKeyboardDismissOnTap(to: view)
        newServiceTextField.addTarget(self, action: #selector(didChange(textField:)), for: .editingChanged)
        title = "New service"
        prepareViewModel()
        startObservingNotifications()
        layout()

        keyboardObserverHandler.onKeyboardNotificationCallback = { [weak self] expanding, notification in
            self?.stackView.spacing = expanding ? Size.textFieldSpacing : Size.componentSpacing
        }
        keyboardObserverHandler.keyboardCollapsedConstraints = [stackViewCenterCollapsedConstraint]
        keyboardObserverHandler.keyboardExpandedConstraints = [stackViewCenterNormalConstraint]
    }

    // MARK: - Private
    private func prepareViewModel() {
        viewModel.createComponentValidator(with: [newServiceTextInput])
        setViewModelOnError()
        viewModel.onSuccess = { [weak self] service in
            self?.delegate?.didCreate(service: service)
        }
        viewModel.afterValidation = { [weak self] success in
            self?.createServiceButton.isEnabled = success
        }
        viewModel.onLoadingChange = { [weak self] loading in
            self?.newServiceTextField.isEnabled = loading
            if loading {
                self?.dismissKeyboard()
                self?.createServiceButton.startLoading()
            } else {
                self?.createServiceButton.stopLoading()
            }
        }
    }

    private func layout() {
        stackViewCenterNormalConstraint = stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        stackViewCenterNormalConstraint.isActive = true
        stackViewCenterCollapsedConstraint = stackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: Size.componentSpacing*3)
    }

    // MARK: TextField
    @objc private func didChange(textField: UITextField) {
        viewModel.serviceName = newServiceTextInput.validatableInput
        viewModel.validate(component: newServiceTextInput)
    }
}
