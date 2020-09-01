//
//  NotifirePopAnimationController.swift
//  Notifire
//
//  Created by David Bielik on 11/11/2018.
//  Copyright © 2018 David Bielik. All rights reserved.
//

import UIKit

class NotifireAlertViewController: NotifirePoppableViewController {

    // MARK: - Properties
    var containerCenterYConstraint: NSLayoutConstraint!

    // MARK: Views
    let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = Theme.defaultCornerRadius
        view.layer.shadowRadius = 6
        view.layer.shadowOpacity = 0.4
        view.layer.shadowOffset = CGSize(width: 0, height: 0)
        return view
    }()

    var viewToPop: UIView {
        return containerView
    }

    let titleLabel = UILabel(style: .alertTitle)

    let informationLabel = UILabel(style: .alertInformation)

    let actionViewsStackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [])
        stack.axis = .vertical
        stack.distribution = .fillProportionally
        stack.alignment = .center
        stack.spacing = 0
        return stack
    }()

    // MARK: Model
    var alertTitle: String? = nil { didSet { updateLabels() } }
    var alertText: String? = nil { didSet { updateLabels() } }
    var actionControls: [NotifireAlertAction: UIControl] = [:]
    var actions: [NotifireAlertAction] = []

    // MARK: - Lifecycle
    init(alertTitle: String?, alertText: String?) {
        self.alertTitle = alertTitle
        self.alertText = alertText
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) { fatalError() }

    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        containerView.backgroundColor = .backgroundColor
        containerView.layoutMargins = UIEdgeInsets(everySide: Size.extendedMargin)
        modalTransitionStyle = .crossDissolve

        updateLabels()
        layout()
        actions.forEach { addToStackView(action: $0) }
    }

    // MARK: - Private
    private func updateLabels() {
        titleLabel.text = alertTitle
        informationLabel.text = alertText
    }

    func layout() {
        view.add(subview: containerView)
        containerView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        containerCenterYConstraint = containerView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        containerCenterYConstraint.isActive = true

        let widthConstraint = containerView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.72)
        widthConstraint.priority = UILayoutPriority(999)
        widthConstraint.isActive = true
        let heightConstraint = containerView.heightAnchor.constraint(lessThanOrEqualTo: view.heightAnchor, multiplier: 0.5)
        heightConstraint.priority = UILayoutPriority(999)
        heightConstraint.isActive = true

        containerView.add(subview: titleLabel)
        titleLabel.topAnchor.constraint(equalTo: containerView.layoutMarginsGuide.topAnchor).isActive = true
        titleLabel.leadingAnchor.constraint(equalTo: containerView.layoutMarginsGuide.leadingAnchor).isActive = true
        titleLabel.trailingAnchor.constraint(equalTo: containerView.layoutMarginsGuide.trailingAnchor).isActive = true

        containerView.add(subview: informationLabel)
        informationLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: Size.textFieldSpacing).isActive = true
        informationLabel.leadingAnchor.constraint(equalTo: containerView.layoutMarginsGuide.leadingAnchor).isActive = true
        informationLabel.trailingAnchor.constraint(equalTo: containerView.layoutMarginsGuide.trailingAnchor).isActive = true

        containerView.add(subview: actionViewsStackView)
        actionViewsStackView.topAnchor.constraint(equalTo: informationLabel.bottomAnchor, constant: Size.componentSpacing).isActive = true
        actionViewsStackView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor).isActive = true
        actionViewsStackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor).isActive = true
        actionViewsStackView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor).isActive = true
    }

    private func addToStackView(action: NotifireAlertAction) {
        guard actionViewsStackView.superview == containerView else { return }
        let newActionControl = ActionButton(type: .system)
        newActionControl.setTitle(action.title, for: .normal)
        newActionControl.onProperTap = {
            action.handler?(action)
        }
        if case .neutral = action.style {
            newActionControl.tintColor = .black
        }
        if case .negative = action.style {
            newActionControl.tintColor = .red
        }
        let separatorView = HairlineView()
        actionViewsStackView.addArrangedSubview(separatorView)
        separatorView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor).isActive = true
        separatorView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor).isActive = true

        actionViewsStackView.addArrangedSubview(newActionControl)
        newActionControl.leadingAnchor.constraint(equalTo: containerView.leadingAnchor).isActive = true
        newActionControl.trailingAnchor.constraint(equalTo: containerView.trailingAnchor).isActive = true
        newActionControl.heightAnchor.constraint(equalToConstant: Size.componentHeight).isActive = true
        actionControls[action] = newActionControl
    }

    // MARK: - Public
    public func add(action: NotifireAlertAction) {
        actions.append(action)
        addToStackView(action: action)
    }
}

class NotifireAlertAction: Hashable {
    static func == (lhs: NotifireAlertAction, rhs: NotifireAlertAction) -> Bool {
        return lhs.title == rhs.title && lhs.style == rhs.style
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(title)
        hasher.combine(style)
    }

    typealias ActionHandler = ((NotifireAlertAction) -> Void)?

    enum Style: Hashable {
        case negative
        case positive
        case neutral
    }

    let title: String
    let style: Style
    let handler: ActionHandler

    init(title: String, style: Style, handler: ActionHandler = nil) {
        self.title = title
        self.style = style
        self.handler = handler
    }
}

class NotifireInputAlertViewController: NotifireAlertViewController, KeyboardObserving {

    // MARK: - Properties
    let viewModel: NotifireAlertViewModel

    // MARK: Views
    var validatableInput: ValidatableTextInput?
    private var validatingAction: NotifireAlertAction?

    // MARK: - Initialization
    init(alertTitle: String?, alertText: String?, viewModel: NotifireAlertViewModel) {
        self.viewModel = viewModel
        super.init(alertTitle: alertTitle, alertText: alertText)
    }

    required init?(coder aDecoder: NSCoder) { fatalError() }

    deinit {
        removeObservers()
    }

    // MARK: - View lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        addKeyboardDismissOnTap(to: view)
        setupObservers()
        setupValidatingAction()
    }

    override func layout() {
        super.layout()
        guard let validatableInput = self.validatableInput else { return }
        actionViewsStackView.insertArrangedSubview(validatableInput, at: 0)
        validatableInput.widthAnchor.constraint(equalTo: titleLabel.widthAnchor).isActive = true
        validatableInput.heightAnchor.constraint(equalToConstant: Size.componentHeight).isActive = true
        actionViewsStackView.setCustomSpacing(Size.extendedMargin, after: validatableInput)
    }

    // MARK: - Private
    private func setupValidatingAction() {
        if let validatingAction = self.validatingAction, let validatableInput = self.validatableInput {
            let controlToEnableAfterValidation = actionControls[validatingAction]
            controlToEnableAfterValidation?.isEnabled = validatableInput.isValid
            viewModel.createComponentValidator(with: [validatableInput])
            viewModel.afterValidation = { valid in
                controlToEnableAfterValidation?.isEnabled = valid
            }
        }
    }

    // MARK: - Public
    public func createValidatableInput(title: String, secure: Bool, rules: [ComponentRule], validatingAction: NotifireAlertAction) {
        guard self.validatableInput == nil else { return }
        let textField = CustomTextField()
        textField.setPlaceholder(text: title)
        textField.isSecureTextEntry = secure
        let validatableInput = ValidatableTextInput(textField: textField)
        validatableInput.validatingViewModelBinder = ValidatingViewModelBinder(viewModel: viewModel, for: .textFieldText)
        validatableInput.rules = rules
        validatableInput.showsValidState = false
        self.validatableInput = validatableInput
        self.validatingAction = validatingAction
    }

    // MARK: - KeyboardObserving
    var observers: [NSObjectProtocol] = []
    lazy var keyboardExpandedConstraints: [NSLayoutConstraint] = []
    lazy var keyboardCollapsedConstraints: [NSLayoutConstraint] = []
    var keyboardAnimationBlock: ((Bool, TimeInterval) -> Void)?

    func onKeyboardChange(expanding: Bool, notification: Notification) {
        if expanding {
            guard let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else {
                return
            }
            let keyboardRectangle = keyboardFrame.cgRectValue
            let keyboardHeight = keyboardRectangle.height
            containerCenterYConstraint.constant = -0.5*keyboardHeight
        } else {
            containerCenterYConstraint.constant = 0
        }
    }
}

final class NotifireAlertViewModel: BindableInputValidatingViewModel {
    func keyPath(for value: KeyPaths) -> ReferenceWritableKeyPath<NotifireAlertViewModel, String> {
        return \.textFieldText
    }

    enum KeyPaths: InputValidatingBindableEnum {
        case textFieldText
    }
    typealias EnumDescribingKeyPaths = KeyPaths

    var textFieldText: String = ""
}

class NotifirePopAnimationController: NSObject, UIViewControllerAnimatedTransitioning {
    var animator: UIViewPropertyAnimator?

    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.48
    }

    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let toVC = transitionContext.viewController(forKey: .to) as? NotifirePoppableViewController
            else { return }

        let containerView = transitionContext.containerView
        let viewToPop = toVC.viewToPop
        toVC.view.alpha = 0
        viewToPop.transform = CGAffineTransform(scaleX: 1.14, y: 1.14)
        containerView.addSubview(toVC.view)
        containerView.bringSubviewToFront(toVC.view)

        let duration = transitionDuration(using: transitionContext)
        let popAnimator = UIViewPropertyAnimator(duration: duration, dampingRatio: 0.65) {
            viewToPop.transform = .identity
            toVC.view.alpha = 1
        }
        popAnimator.addCompletion { _ in
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        }
        popAnimator.isUserInteractionEnabled = true
        animator = popAnimator
        popAnimator.startAnimation()
    }
}
