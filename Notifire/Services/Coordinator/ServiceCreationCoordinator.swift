//
//  ServiceCreationCoordinator.swift
//  Notifire
//
//  Created by David Bielik on 19/12/2020.
//  Copyright © 2020 David Bielik. All rights reserved.
//

import UIKit
import CropViewController

/// Represents a Coordinator that can present another Coordinator or ViewController.
protocol PresentingCoordinator: Coordinator {
    /// The currently presented coordinator
    var presentedCoordinator: ChildCoordinator? { get set }
    /// The `UIViewController` that presents a new ChildCoordinator
    var presentingViewController: UIViewController? { get }

    /// Present a new `ChildCoordinator` if presentedCoordinator is nil.
    func present(childCoordinator: ChildCoordinator, animated: Bool, modalPresentationStyle: UIModalPresentationStyle)
    /// Dismiss `presentedCoordinator`
    func dismissPresentedCoordinator(animated: Bool, completion: (() -> Void)?)
}

extension PresentingCoordinator where Self: ChildCoordinator {
    var presentingViewController: UIViewController? {
        return viewController
    }
}

private extension UIModalPresentationStyle {
    static var defaultValue: UIModalPresentationStyle {
        guard #available(iOS 13, *) else {
            return .fullScreen
        }
        return .automatic
    }
}

extension PresentingCoordinator {
    func present(childCoordinator: ChildCoordinator, animated: Bool, modalPresentationStyle: UIModalPresentationStyle = .defaultValue) {
        guard presentedCoordinator == nil else { return }

        presentedCoordinator = childCoordinator
        childCoordinator.viewController.modalPresentationStyle = modalPresentationStyle
        childCoordinator.start()
        presentingViewController?.present(childCoordinator.viewController, animated: animated, completion: nil)
    }

    /// Convenience method to present a `UIViewController` which will get encapsulated in a `GenericCoordinator`
    func present(viewController: UIViewController, animated: Bool, modalPresentationStyle: UIModalPresentationStyle = .defaultValue) {
        let coordinator = GenericCoordinator(viewController: viewController)
        present(childCoordinator: coordinator, animated: animated, modalPresentationStyle: modalPresentationStyle)
    }

    func dismissPresentedCoordinator(animated: Bool, completion: (() -> Void)? = nil) {
        guard presentedCoordinator != nil else { return }

        presentingViewController?.dismiss(animated: animated, completion: { [weak self] in
            self?.presentedCoordinator = nil
            completion?()
        })
    }
}

// MARK: - Service Name
class ServiceNameCreationViewModel: InputValidatingViewModel, APIErrorProducing {

    // MARK: - Properties
    let protectedApiManager: NotifireProtectedAPIManager
    var name: String = ""
    var imageData: Data?

    let loadingModel = LoadingModel()

    // MARK: APIErrorProducing
    var onError: ((NotifireAPIError) -> Void)?

    // MARK: Callback
    /// Called when a service creation request is finished. Parameter is `true` if the service was created successfully.
    var onServiceCreated: ((Bool) -> Void)?

    // MARK: - Initialization
    init(protectedApiManager: NotifireProtectedAPIManager) {
        self.protectedApiManager = protectedApiManager
        super.init()
    }

    // MARK: - Methods
    func createNewService() {
        guard allComponentsValidated, !loadingModel.isLoading else { return }
        loadingModel.toggle()

        protectedApiManager.createService(name: name, imageData: imageData) { [weak self] result in
            guard let `self` = self else { return }
            self.loadingModel.toggle()

            switch result {
            case .error(let error):
                self.onError?(error)
            case .success(let response):
                self.onServiceCreated?(response.success)
            }
        }
    }
}

class TitleAndInformationView: ConstrainableView {

    // MARK: - Properties
    public var titleText: String = "" { didSet { titleLabel.text = titleText } }
    public var informationText: String = "" { didSet { informationLabel.text = informationText } }

    // MARK: UI
    lazy var titleLabel = UILabel(style: .title, text: titleText, alignment: .center)
    lazy var informationLabel = UILabel(style: .centeredDimmedLightInformation, text: informationText, alignment: .center)

    // MARK: - Inherited
    override open func setupSubviews() {
        super.setupSubviews()

        add(subview: titleLabel)
        titleLabel.topAnchor.constraint(equalTo: topAnchor).isActive = true
        titleLabel.embedSides(in: self)

        add(subview: informationLabel)
        informationLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: Size.componentSpacing).isActive = true
        informationLabel.embedSides(in: self)
        informationLabel.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
    }
}

class ServiceNameCreationViewController: VMViewController<ServiceNameCreationViewModel>, CenterStackViewPresenting, KeyboardFollowingButtonContaining, APIErrorResponding, APIErrorPresenting, NotifireAlertPresenting {

    // MARK: - Properties
    lazy var textFieldReturnChainer = TextFieldReturnChainer(textField: serviceNameTextInput.textField, setLastReturnKeyTypeToDone: true) { [weak self] in
        self?.viewModel.createNewService()
    }

    // MARK: UI
    lazy var titleAndInformationView: TitleAndInformationView = {
        let view = TitleAndInformationView()
        view.titleText = "Pick a name"
        view.informationText = "Choose a descriptive name for your new service."
        return view
    }()

    lazy var serviceNameTextInput: ValidatableTextInput = {
        let textField = BottomBarTextField()
        textField.setPlaceholder(text: "New service name")
        let input = ValidatableTextInput(textField: textField)
        input.rules = ComponentRule.serviceNameRules
        input.validatingViewModelBinder = ValidatingViewModelBinder(viewModel: viewModel, for: \.name)
        return input
    }()

    lazy var finishButton: NotifireButton = {
        let button = NotifireButton()
        button.isEnabled = false
        button.setTitle("Create service", for: .normal)
        button.onProperTap = { [unowned self] _ in
            self.viewModel.createNewService()
        }
        return button
    }()

    // MARK: KeyboardFollowingButtonContaining
    var keyboardObserverHandler = KeyboardObserverHandler()
    var shouldAddKeyboardFollowingContainer: Bool { return false }

    // MARK: Callbacks
    /// Called when the user presses Cancel
    var onFinishPress: (() -> Void)?

    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // Appearance
        view.backgroundColor = .compatibleSystemBackground

        setupSubviews()
        prepareViewModel()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // Observers
        startObservingNotifications()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stopObservingNotifications()
    }

    deinit {
        stopObservingNotifications()
    }

    // MARK: - Private

    private func setupSubviews() {
        view.add(subview: titleAndInformationView)
        titleAndInformationView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: Size.componentSpacing).isActive = true
        titleAndInformationView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        titleAndInformationView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: Size.componentWidthRelativeToScreenWidth).isActive = true

        view.add(subview: serviceNameTextInput)
        serviceNameTextInput.topAnchor.constraint(equalTo: titleAndInformationView.bottomAnchor, constant: Size.componentSpacing * 2).isActive = true
        serviceNameTextInput.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        serviceNameTextInput.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: Size.componentWidthRelativeToScreenWidth).isActive = true

        addKeyboardFollowing(button: finishButton)
    }

    private func prepareViewModel() {
        viewModel.createComponentValidator(with: [serviceNameTextInput])

        viewModel.afterValidation = { [weak self] success in
            self?.finishButton.isEnabled = success
        }

        viewModel.loadingModel.onLoadingChange = { [weak self] loading in
            self?.serviceNameTextInput.textField.isEnabled = !loading
            self?.finishButton.changeLoading(to: loading)
        }

        setViewModelOnError()
    }
}

// MARK: - Service Image
class ServiceImageCreationCoordinator: NSObject, ChildCoordinator, PresentingCoordinator {

    // MARK: - Properties
    var viewController: UIViewController {
        return serviceImageCreationViewController
    }

    let serviceImageCreationViewController: ServiceImageCreationViewController

    // MARK: PresentingCoordinator
    var presentedCoordinator: ChildCoordinator?

    // MARK: - Initialization
    init(imageCreationVM: ServiceImageCreationViewModel) {
        self.serviceImageCreationViewController = ServiceImageCreationViewController(viewModel: imageCreationVM)
    }

    func start() {
        serviceImageCreationViewController.onImageAddPress = { [weak self] in
            self?.showImagePicker()
        }
    }

    func showImagePicker() {
        guard UIImagePickerController.isSourceTypeAvailable(.photoLibrary) else {
            // Present Alert
            let alertController = UIAlertController(title: "Photos unavailable", message: "There was a problem with accessing your photos. Please verify that you photo library is not empty.", preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "Ok", style: .default) { [weak self] _ in
                self?.dismissPresentedCoordinator(animated: true)
            })
            present(viewController: alertController, animated: true)
            return
        }
        // Present Picker
        let pickerController = UIImagePickerController()
        pickerController.delegate = self
        pickerController.mediaTypes = ["public.image"]
        pickerController.sourceType = .photoLibrary
        present(viewController: pickerController, animated: true)
    }
}

extension ServiceImageCreationCoordinator: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismissPresentedCoordinator(animated: true)
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        guard let image = info[.originalImage] as? UIImage else { return }
        dismissPresentedCoordinator(animated: true) { [weak self] in
            let cropVC = CustomCropViewController(croppingStyle: .circular, image: image)
            cropVC.delegate = self
            self?.present(viewController: cropVC, animated: true, modalPresentationStyle: .fullScreen)
        }
    }
}

class CustomCropViewController: CropViewController {

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        toolbar.subviews.map({ ($0 as? UIButton) }).forEach({ $0?.setTitleColor(.primary, for: .normal) })
    }
}

extension ServiceImageCreationCoordinator: CropViewControllerDelegate {
    func cropViewController(_ cropViewController: CropViewController, didFinishCancelled cancelled: Bool) {
        dismissPresentedCoordinator(animated: true)
    }

    func cropViewController(_ cropViewController: CropViewController, didCropToCircularImage image: UIImage, withRect cropRect: CGRect, angle: Int) {
        serviceImageCreationViewController.update(image: image)
        dismissPresentedCoordinator(animated: true)
    }
}

class ServiceImageCreationViewModel: ViewModelRepresenting {}

class ServiceImageCreationViewController: VMViewController<ServiceImageCreationViewModel>, NavigationBarDisplaying {

    // MARK: - Properties
    // MARK: UI
    lazy var titleAndInformationView: TitleAndInformationView = {
        let view = TitleAndInformationView()
        view.titleText = "Pick an image"
        view.informationText = "Have an image that represents your new service? Upload it now."
        return view
    }()

    lazy var imageView: RoundedEditableImageView = {
        let view = RoundedEditableImageView(image: LocalService.defaultImage)
        view.onUserAction = { [unowned self] in
            self.onImageAddPress?()
        }
        return view
    }()

    lazy var continueButton: NotifireButton = {
        let button = NotifireButton()
        button.isEnabled = false
        button.setTitle("Next", for: .normal)
        button.onProperTap = { [unowned self] _ in
            self.onContinuePress?(self.imageView.image?.pngData())
        }
        return button
    }()

    lazy var skipButton: ActionButton = {
        let button = ActionButton.createActionButton(text: "Skip for now") { [unowned self] _ in
            self.onContinuePress?(nil)
        }
        button.titleLabel?.set(style: .actionButton)
        return button
    }()

    // MARK: Callbacks
    /// Called when the user wants to add a new image.
    var onImageAddPress: (() -> Void)?
    /// Called when the user presses Cancel
    var onCancelPress: (() -> Void)?
    /// Called when the user continues to the next screen. The parameter of this property may contain the service image.
    var onContinuePress: ((Data?) -> Void)?

    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // Appearance
        view.backgroundColor = .compatibleSystemBackground

        // Navigation Bar
        hideNavigationBarBackButtonText()

        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(didSelectCancelCreationButton))

        setupSubviews()
    }

    private func setupSubviews() {
        view.add(subview: titleAndInformationView)
        titleAndInformationView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: Size.componentSpacing).isActive = true
        titleAndInformationView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        titleAndInformationView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: Size.componentWidthRelativeToScreenWidth).isActive = true

        view.add(subview: imageView)
        imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        imageView.widthAnchor.constraint(equalToConstant: Size.Image.extraLargeService).isActive = true
        imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor).isActive = true
        imageView.topAnchor.constraint(equalTo: titleAndInformationView.bottomAnchor, constant: Size.componentSpacing * 3).isActive = true

        view.add(subview: skipButton)
        skipButton.bottomAnchor.constraint(lessThanOrEqualTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -Size.textFieldSpacing).isActive = true
        skipButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true

        view.add(subview: continueButton)
        continueButton.bottomAnchor.constraint(equalTo: skipButton.topAnchor, constant: -Size.textFieldSpacing).isActive = true
        continueButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        continueButton.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: Size.componentWidthRelativeToScreenWidth).isActive = true
    }

    @objc private func didSelectCancelCreationButton() {
        onCancelPress?()
    }

    func update(image: UIImage?) {
        imageView.image = image

        continueButton.isEnabled = image != nil
    }
}

// MARK: - Service Creation
protocol ServiceCreationCoordinatorDelegate: class {
    func didCancelServiceCreation()
    func didFinishServiceCreation()
}

class ServiceCreationNavigationController: NotifireNavigationController, NotifireAlertPresenting {

    override func viewDidLoad() {
        navigationBarTintColor = .primary
        super.viewDidLoad()

        if #available(iOS 13, *) {
            let appearance = UINavigationBarAppearance()
            appearance.configureWithDefaultBackground()
            appearance.backgroundColor = .compatibleSystemBackground
            appearance.shadowImage = UIImage()
            appearance.shadowColor = .clear
            navigationBar.standardAppearance = appearance
            navigationBar.compactAppearance = appearance
            navigationBar.scrollEdgeAppearance = appearance
        } else {
            navigationBar.barTintColor = .compatibleSystemBackground
            navigationBar.shadowImage = UIImage()
        }

        title = "New service"
    }
}

class ServiceCreationCoordinator: NavigationCoordinator<ServiceImageCreationCoordinator> {

    // MARK: - Properties
    weak var serviceCreationDelegate: ServiceCreationCoordinatorDelegate?
    let protectedApiManager: NotifireProtectedAPIManager

    // MARK: - Initialization
    init(protectedApiManager: NotifireProtectedAPIManager) {
        self.protectedApiManager = protectedApiManager
        let viewModel = ServiceImageCreationViewModel()
        let rootCoordinator = ServiceImageCreationCoordinator(imageCreationVM: viewModel)
        super.init(rootChildCoordinator: rootCoordinator, navigationController: ServiceCreationNavigationController())
    }

    override func start() {
        rootChildCoordinator.serviceImageCreationViewController.onCancelPress = { [weak self] in
            self?.serviceCreationDelegate?.didCancelServiceCreation()
        }
        rootChildCoordinator.serviceImageCreationViewController.onContinuePress = { [weak self] data in
            self?.showServiceNameCreation(imageData: data)
        }
        super.start()
    }

    private func presentServiceAlreadyExistsError() {
        let alertVC = NotifireAlertViewController(alertTitle: "Oops, try another name.", alertText: "You already have a service with this name. Try to come up with something else.")
        alertVC.add(action: NotifireAlertAction(title: "Ok", style: .neutral, handler: { [weak self] _ in
            self?.navigationController.dismiss(animated: true, completion: nil)
        }))
        (navigationController as? NotifireAlertPresenting)?.present(alert: alertVC, animated: true, completion: nil)

    }

    private func showServiceNameCreation(imageData: Data?) {
        let viewModel = ServiceNameCreationViewModel(protectedApiManager: protectedApiManager)
        viewModel.imageData = imageData
        viewModel.onServiceCreated = { [weak self] created in
            if created {
                self?.serviceCreationDelegate?.didFinishServiceCreation()
            } else {
                self?.presentServiceAlreadyExistsError()
            }
        }
        let viewController = ServiceNameCreationViewController(viewModel: viewModel)
        push(childCoordinator: GenericCoordinator(viewController: viewController))
    }
}
