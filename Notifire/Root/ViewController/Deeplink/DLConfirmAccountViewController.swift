//
//  DLConfirmAccountViewController.swift
//  Notifire
//
//  Created by David Bielik on 12/10/2018.
//  Copyright © 2018 David Bielik. All rights reserved.
//

import UIKit

class DLConfirmAccountViewController: DeeplinkedVMViewController<DLConfirmAccountViewModel>, CenterStackViewPresenting, APIErrorResponding, APIErrorPresenting, UserErrorResponding {

    // MARK: - Properties
    // MARK: Views
    let titleLabel: UILabel = {
        let label = UILabel(style: .largeTitle)
        label.text = "Account confirmation"
        return label
    }()

    lazy var confirmationButton: NotifireButton = {
        let button = NotifireButton()
        button.setTitle("Confirm account", for: .normal)
        button.onProperTap = { [weak self] _ in
            self?.viewModel.confirmAccount()
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
        viewModel.onLoadingChange = { [weak self] loading in
            if loading {
                self?.confirmationButton.startLoading()
            } else {
                self?.confirmationButton.stopLoading()
            }
        }
        setViewModelOnUserError()
        setViewModelOnError()
    }

    private func layout() {
        view.add(subview: titleLabel)
        titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: Size.componentSpacing * 2).isActive = true

        let stackView = insertStackView(arrangedSubviews: [confirmationButton], spacing: Size.componentSpacing)
        stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
    }
}

// MARK: - NotifirePoppablePresenting
extension DLConfirmAccountViewController: NotifireAlertPresenting {
    func dismissCompletion(error: UserErrorRepresenting) {
        view.isUserInteractionEnabled = false
        delegate?.shouldCloseDeeplink()
    }

    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return animationController(forPresented: presented)
    }
}
