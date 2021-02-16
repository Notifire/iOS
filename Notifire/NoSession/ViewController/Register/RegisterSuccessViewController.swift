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
    weak var delegate: RegisteringViewControllerDelegate?

    /// The seconds left on a resend confirmation email timer.
    static var resendWaitTimeIntervalInSeconds: TimeInterval = 45
    var resendTimerSecondsLeft: TimeInterval?
    var resendTimer: Timer?

    // MARK: Views
    lazy var titleLabel = UILabel(style: .title, text: "Success! 🎉", alignment: .center)

    lazy var choiceSeparatorView = ChoiceSeparatorView()

    lazy var confirmationInformationLabel: UILabel = {
        let label = UILabel(style: .informationHeader)
        label.textAlignment = .center
        label.numberOfLines = 0
        label.text = "We sent you a link! Open it to continue to your account."
        return label
    }()

    lazy var resendConfirmationEmailButton: ActionButton = {
        let button = ActionButton(type: .system)
        button.setTitle(viewModel.resendConfirmationText, for: .normal)
        button.onProperTap = { [unowned self] _ in
            self.viewModel.resendEmail()
        }
        return button
    }()

    // MARK: BottomNavigatorLabelContaining
    lazy var bottomNavigator: UIView = defaultBottomNavigatorView()
    lazy var bottomNavigatorLabel: UILabel = {
        let label = TappableLabel.createBottomNavigatorSignInLabel()
        label.onHypertextTapped = { [weak self] in
            self?.delegate?.shouldSignInInsteadOfRegister()
        }
        return label
    }()

    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .compatibleSystemBackground

        // navigation bar
        navigationItem.setHidesBackButton(true, animated: false)
        navigationController?.interactivePopGestureRecognizer?.isEnabled = false

        // viewModel
        viewModel.onResendButtonStateChange = { newState in
            switch newState {
            case .finished:
                self.resendConfirmationEmailButton.stopLoading()
                self.startResendTimer()
            case .loading:
                self.resendConfirmationEmailButton.startLoading()
            }
        }

        layout()

        // Animation
        confirmationInformationLabel.alpha = 0
        choiceSeparatorView.alpha = 0
        resendConfirmationEmailButton.alpha = 0
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        // Animate views
        confirmationInformationLabel.transform = CGAffineTransform.identity.translatedBy(x: 0, y: -20)
        choiceSeparatorView.transform = CGAffineTransform.identity.translatedBy(x: 0, y: -12)
        resendConfirmationEmailButton.transform = CGAffineTransform.identity.translatedBy(x: 0, y: -5)

        let animator = UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 0.8, delay: 0.1, options: .curveEaseOut, animations: {
            self.confirmationInformationLabel.transform = .identity
            self.confirmationInformationLabel.alpha = 1
        }, completion: nil)
        animator.addCompletion { _ in
            UIView.animateKeyframes(withDuration: 0.8, delay: 1, options: [], animations: {
                UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 0.7) {
                    self.choiceSeparatorView.transform = .identity
                    self.choiceSeparatorView.alpha = 1
                }
                UIView.addKeyframe(withRelativeStartTime: 0.4, relativeDuration: 0.6) {
                    self.resendConfirmationEmailButton.transform = .identity
                    self.resendConfirmationEmailButton.alpha = 1
                }
            })
        }
    }

    // MARK: - Private
    private func layout() {
        addBottomNavigator()
        addBottomNavigatorLabel()

        view.add(subview: titleLabel)
        titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: Size.componentSpacing).isActive = true
        titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        titleLabel.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: Size.componentWidthRelativeToScreenWidth).isActive = true

        let stackView = insertStackView(arrangedSubviews: [confirmationInformationLabel, choiceSeparatorView, resendConfirmationEmailButton], spacing: Size.componentSpacing)
        stackView.topAnchor.constraint(lessThanOrEqualTo: titleLabel.bottomAnchor, constant: Size.componentSpacing * 2).isActive = true
        stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
    }

    private func startResendTimer() {
        guard resendConfirmationEmailButton.isEnabled else { return }
        resendConfirmationEmailButton.isEnabled = false
        resendTimerSecondsLeft = Self.resendWaitTimeIntervalInSeconds
        didFireResendTimer(animated: true)
        resendTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(didFireResendTimer), userInfo: nil, repeats: true)
    }

    private func stopResendTimer() {
        guard !resendConfirmationEmailButton.isEnabled else { return }
        resendTimerSecondsLeft = nil
        resendTimer?.invalidate()
        resendConfirmationEmailButton.setTitle(viewModel.resendConfirmationText, for: .normal)
        resendConfirmationEmailButton.isEnabled = true
    }

    // MARK: Event Handling
    @objc private func didFireResendTimer(animated: Bool = false) {
        guard let secondsLeft = resendTimerSecondsLeft else { return }
        guard secondsLeft > 0 else {
            stopResendTimer()
            return
        }
        resendTimerSecondsLeft = secondsLeft - 1
        let newButtonTitle = viewModel.resendConfirmationText + " (\(Int(secondsLeft))s)"
        if animated {
            resendConfirmationEmailButton.setTitle(newButtonTitle, for: .normal)
        } else {
            UIView.setAnimationsEnabled(false)
            resendConfirmationEmailButton.setTitle(newButtonTitle, for: .normal)
            resendConfirmationEmailButton.layoutIfNeeded()
            UIView.setAnimationsEnabled(true)
        }
    }
}
