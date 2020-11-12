//
//  ConfirmEmailViewController.swift
//  Notifire
//
//  Created by David Bielik on 12/10/2018.
//  Copyright © 2018 David Bielik. All rights reserved.
//

import UIKit

class ConfirmEmailViewController: VMViewController<ConfirmEmailViewModel>, CenterStackViewPresenting, APIFailableResponding, APIFailableDisplaying, UserErrorFailableResponding {

    // MARK: - Properties
    weak var sessionDelegate: UserSessionCreationDelegate?
    weak var delegate: ConfirmEmailViewControllerDelegate?

    // MARK: Views
    let titleLabel: UILabel = {
        let label = UILabel(style: .largeTitle)
        label.text = "Account confirmation"
        return label
    }()

    lazy var confirmationButton: NotifireButton = {
        let button = NotifireButton()
        button.setTitle("Confirm account", for: .normal)
        button.onProperTap = viewModel.confirmAccount
        return button
    }()

    lazy var cancelButton: ActionButton = {
        let button = ActionButton(type: .system)
        button.setTitle("Cancel", for: .normal)
        button.onProperTap = { [unowned self] _ in
            self.delegate?.didFinishEmailConfirmation()
        }
        return button
    }()

    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .compatibleSystemBackground

        prepareViewModel()
        layout()
    }

    // MARK: - Private
    private func prepareViewModel() {
        viewModel.onConfirmation = { [weak self] session in
            self?.sessionDelegate?.didCreate(session: session)
        }

        viewModel.onLoadingChange = { [weak self] loading in
            if loading {
                self?.confirmationButton.startLoading()
                self?.cancelButton.isEnabled = false
            } else {
                self?.confirmationButton.stopLoading()
                self?.cancelButton.isEnabled = true
            }
        }
        setViewModelOnUserError()
        setViewModelOnError()
    }

    private func layout() {
        view.add(subview: titleLabel)
        titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: Size.componentSpacing * 2).isActive = true

        let stackView = insertStackView(arrangedSubviews: [confirmationButton, ChoiceSeparatorView(), cancelButton], spacing: Size.componentSpacing)
        stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
    }
}

// MARK: - NotifirePoppablePresenting
extension ConfirmEmailViewController: NotifireAlertPresenting {
    func dismissCompletion(error: UserErrorRepresenting) {
        view.isUserInteractionEnabled = false
        delegate?.didFinishEmailConfirmation()
    }

    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return animationController(forPresented: presented)
    }
}
