//
//  NotifirePopAnimationController.swift
//  Notifire
//
//  Created by David Bielik on 11/11/2018.
//  Copyright © 2018 David Bielik. All rights reserved.
//

import UIKit

class NotifireAlertViewController: NotifirePoppableViewController {

    enum AlertStyle: Equatable {
        /// The alert style to use for alerts that show a successful user action. (shows a checkmark ✅)
        case success
        /// The alert style to use for alerts that show that something failed (shows a cross ❌)
        case fail

        var image: UIImage {
            return self == .success ? #imageLiteral(resourceName: "checkmark.circle") : #imageLiteral(resourceName: "xmark.circle")
        }

        var color: UIColor {
            return self == .success ? .compatibleGreen : .compatibleRed
        }
    }

    // MARK: - Properties
    var containerCenterYConstraint: NSLayoutConstraint!

    private static let verticalMargin: CGFloat = Size.standardMargin * 1.5

    // MARK: Views
    let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .compatibleSecondarySystemGroupedBackground
        view.layer.cornerRadius = Theme.alertCornerRadius
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
    /// The title of the alert
    var alertTitle: String? { didSet { updateLabels() } }
    /// The main text of the alert
    var alertText: String? { didSet { updateLabels() } }
    /// The style of the alert displayed (optional)
    let alertStyle: AlertStyle?
    var actionControls: [NotifireAlertAction: UIControl] = [:]
    var actions: [NotifireAlertAction] = []

    // MARK: - Lifecycle
    init(alertTitle: String?, alertText: String?, alertStyle: AlertStyle? = nil) {
        self.alertTitle = alertTitle
        self.alertText = alertText
        self.alertStyle = alertStyle
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) { fatalError() }

    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        containerView.layoutMargins = UIEdgeInsets(top: Self.verticalMargin, left: Size.extendedMargin, bottom: Self.verticalMargin, right: Size.extendedMargin)
        modalTransitionStyle = .crossDissolve

        updateLabels()
        layout()
        setAlertStyleImageIfNeeded()
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

        // Title
        containerView.add(subview: titleLabel)
        // lower the title priority because if the image is present it needs to be above the titleLabel
        let titleTopAnchor = titleLabel.topAnchor.constraint(equalTo: containerView.layoutMarginsGuide.topAnchor)
        titleTopAnchor.priority = .init(950)
        titleTopAnchor.isActive = true
        titleLabel.leadingAnchor.constraint(equalTo: containerView.layoutMarginsGuide.leadingAnchor).isActive = true
        titleLabel.trailingAnchor.constraint(equalTo: containerView.layoutMarginsGuide.trailingAnchor).isActive = true

        containerView.add(subview: informationLabel)
        informationLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: Size.textFieldSpacing * 0.5).isActive = true
        informationLabel.leadingAnchor.constraint(equalTo: containerView.layoutMarginsGuide.leadingAnchor).isActive = true
        informationLabel.trailingAnchor.constraint(equalTo: containerView.layoutMarginsGuide.trailingAnchor).isActive = true

        containerView.add(subview: actionViewsStackView)
        actionViewsStackView.topAnchor.constraint(equalTo: informationLabel.bottomAnchor, constant: Self.verticalMargin).isActive = true
        actionViewsStackView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor).isActive = true
        actionViewsStackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor).isActive = true
        actionViewsStackView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor).isActive = true
    }

    private func setAlertStyleImageIfNeeded() {
        guard let style = alertStyle else { return }
        let imageView = UIImageView(image: style.image.withRenderingMode(.alwaysTemplate))
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = style.color
        containerView.add(subview: imageView)
        imageView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor).isActive = true
        imageView.topAnchor.constraint(equalTo: containerView.layoutMarginsGuide.topAnchor).isActive = true
        imageView.bottomAnchor.constraint(equalTo: titleLabel.topAnchor, constant: -Size.extendedMargin).isActive = true
        imageView.widthAnchor.constraint(equalTo: imageView.heightAnchor).isActive = true
        imageView.heightAnchor.constraint(equalToConstant: Size.Image.alertSuccessFailImage).isActive = true
        imageView.setContentCompressionResistancePriority(.init(1000), for: .vertical)
    }

    private func addToStackView(action: NotifireAlertAction) {
        guard actionViewsStackView.superview == containerView else { return }
        let newActionControl = ActionButton(type: .system)
        newActionControl.titleLabel?.set(style: .alertAction)
        newActionControl.setTitle(action.title, for: .normal)
        newActionControl.onProperTap = { _ in
            action.handler?(action)
        }
        if case .neutral = action.style {
            newActionControl.tintColor = .compatibleLabel
        }
        if case .negative = action.style {
            newActionControl.tintColor = .compatibleRed
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
        stopObservingNotifications()
    }

    // MARK: - View lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        addKeyboardDismissOnTap(to: view)
        startObservingNotifications()
        setupValidatingAction()

        keyboardObserverHandler.onKeyboardNotificationCallback = { [weak self] expanding, notification in
            if expanding {
                guard let keyboardHeight = self?.keyboardObserverHandler.keyboardHeight(from: notification) else { return }
                self?.containerCenterYConstraint.constant = -0.5*keyboardHeight
            } else {
                self?.containerCenterYConstraint.constant = 0
            }
        }
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
        let textField = BorderedTextField()
        textField.setPlaceholder(text: title)
        textField.isSecureTextEntry = secure
        let validatableInput = ValidatableTextInput(textField: textField)
        validatableInput.validatingViewModelBinder = ValidatingViewModelBinder(viewModel: viewModel, for: \.textFieldText)
        validatableInput.rules = rules
        validatableInput.showsValidState = false
        self.validatableInput = validatableInput
        self.validatingAction = validatingAction
    }

    // MARK: - KeyboardObserving
    var keyboardObserverHandler = KeyboardObserverHandler()
}

final class NotifireAlertViewModel: InputValidatingViewModel {
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
