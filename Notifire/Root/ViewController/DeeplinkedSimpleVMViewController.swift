//
//  DeeplinkedSimpleVMViewController.swift
//  Notifire
//
//  Created by David Bielik on 19/11/2020.
//  Copyright © 2020 David Bielik. All rights reserved.
//

import UIKit

class DeeplinkedSimpleVMViewController<VM: DeeplinkViewModelRepresenting>: DeeplinkedVMViewController<VM>, CenterStackViewPresenting, UserErrorResponding, APIErrorResponding, APIErrorPresenting {

    // MARK: - Propertie
    // MARK: UI
    lazy var headerLabel = UILabel(style: .title, text: viewModel.headerText, alignment: .left)

    lazy var loadingIndicator = UIActivityIndicatorView.loadingIndicator

    lazy var loadingLabel = UILabel(style: .centeredDimmedLightInformation, text: viewModel.loadingText, alignment: .center)

    lazy var reloadButton = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(didSelectReloadButton))

    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        prepareViewModel()

        handleViewModelStateChange(.initial, .initial)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        viewModel.startMainDeeplinkAction()
    }

    override func setupSubviews() {
        super.setupSubviews()

        view.add(subview: headerLabel)
        headerLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: Size.doubleMargin).isActive = true

        let stackView = insertStackView(arrangedSubviews: [loadingIndicator, loadingLabel], spacing: Size.textFieldSpacing)
        stackView.topAnchor.constraint(equalTo: headerLabel.bottomAnchor, constant: Size.componentSpacing * 4).isActive = true

        headerLabel.leadingAnchor.constraint(equalTo: loadingLabel.leadingAnchor).isActive = true
    }

    // MARK: - Open
    open func prepareViewModel() {

        viewModel.stateModel.onStateChange = { [weak self] old, new in
            self?.handleViewModelStateChange(old, new)
        }

        setViewModelOnError()
        setViewModelOnUserError()
    }

    open func handleViewModelStateChange(_ old: DeeplinkViewState, _ new: DeeplinkViewState) {
        switch new {
        case .initial, .confirming:
            navigationItem.leftBarButtonItem?.isEnabled = false
            navigationItem.rightBarButtonItem = nil
            loadingIndicator.startAnimating()
            loadingLabel.alpha = 1
        case .failed:
            navigationItem.leftBarButtonItem?.isEnabled = true
            navigationItem.rightBarButtonItem = reloadButton
            loadingIndicator.stopAnimating()
            loadingLabel.alpha = 0
        case .success:
            beginSuccessAnimation()
        }
    }

    // MARK: - Private
    private func beginSuccessAnimation() {
        // Checkmark
        let checkmarkImageView = UIImageView(image: #imageLiteral(resourceName: "checkmark.circle").withRenderingMode(.alwaysTemplate))
        checkmarkImageView.tintColor = .compatibleGreen
        checkmarkImageView.alpha = 0
        checkmarkImageView.transform = CGAffineTransform.identity.scaledBy(x: 0.3, y: 0.3)
        view.add(subview: checkmarkImageView)
        checkmarkImageView.heightAnchor.constraint(equalToConstant: 128).isActive = true
        checkmarkImageView.widthAnchor.constraint(equalTo: checkmarkImageView.heightAnchor).isActive = true
        checkmarkImageView.centerXAnchor.constraint(equalTo: loadingIndicator.centerXAnchor).isActive = true
        checkmarkImageView.centerYAnchor.constraint(equalTo: loadingIndicator.centerYAnchor).isActive = true

        // Checkmark animator
        let animator = UIViewPropertyAnimator(duration: 0.25, dampingRatio: 0.7) {
            checkmarkImageView.alpha = 1
            checkmarkImageView.transform = .identity
        }

        // Animate indicator + label
        UIView.animateKeyframes(withDuration: 0.2, delay: 0, options: .init(animationOptions: .curveEaseOut), animations: {
            UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 0.8) {
                self.loadingLabel.transform = CGAffineTransform.identity.translatedBy(x: -40, y: 0)
            }
            UIView.addKeyframe(withRelativeStartTime: 0.1, relativeDuration: 0.7) {
                self.loadingIndicator.transform = CGAffineTransform.identity.translatedBy(x: -15, y: 0)
            }
            UIView.addKeyframe(withRelativeStartTime: 0.3, relativeDuration: 0.7) {
                self.loadingLabel.alpha = 0
                self.loadingIndicator.alpha = 0
            }
        }, completion: { _ in
            animator.startAnimation()
        })
    }

    // MARK: - Event Handling
    @objc private func didSelectReloadButton() {
        // Start action on reload tap
        viewModel.startMainDeeplinkAction()
    }

    // MARK: - UserErrorPresenting
    func dismissCompletion(error: VM.UserError) {
        // Close the deeplink when we dismiss an EmailTokenError
        delegate?.shouldCloseDeeplink()
    }

    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return animationController(forPresented: presented)
    }
}
