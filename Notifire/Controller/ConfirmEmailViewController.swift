//
//  ConfirmEmailViewController.swift
//  Notifire
//
//  Created by David Bielik on 12/10/2018.
//  Copyright © 2018 David Bielik. All rights reserved.
//

import UIKit

protocol NotifireUserSessionCreationDelegate: class {
    func didCreate(session: NotifireUserSession)
}

protocol ConfirmEmailViewControllerDelegate: class {
    func didFinishEmailConfirmation()
}

class ConfirmEmailViewController: UIViewController, CenterStackViewPresenting, APIFailableResponding, APIFailableDisplaying, UserErrorFailableResponding {
    
    // MARK: - Properties
    let viewModel: ConfirmEmailViewModel
    weak var sessionDelegate: NotifireUserSessionCreationDelegate?
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
        button.onProperTap = { [unowned self] in
            self.delegate?.didFinishEmailConfirmation()
        }
        return button
    }()
    
    // MARK: - Initialization
    init(viewModel: ConfirmEmailViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) { fatalError() }
    
    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .backgroundColor
        
        prepareViewModel()
        layout()
    }
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        guard presented is NotifirePoppable else { return nil }
        return NotifirePopAnimationController()
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

extension ConfirmEmailViewController: NotifirePoppablePresenting {
    func dismissCompletion(error: UserErroRepresenting) {
        view.isUserInteractionEnabled = false
        delegate?.didFinishEmailConfirmation()
    }
}
