//
//  ServiceCoordinator.swift
//  Notifire
//
//  Created by David Bielik on 13/11/2020.
//  Copyright © 2020 David Bielik. All rights reserved.
//

import UIKit

class ServiceEditViewModel: InputValidatingViewModel, ImageDataContainingViewModel, APIErrorProducing {

    // MARK: - Properties
    var editedServiceName = ""

    let sessionHandler: UserSessionHandler
    let service: LocalService

    let loadingModel = LoadingModel()

    var title: String {
        return "Edit service"
    }

    // MARK: Ready to edit
    var serviceNameValidated: Bool = false {
        didSet {
            updateReadyToEditService()
        }
    }
    var imageValidated: Bool {
        return imageData != nil
    }

    var readyToEditService: Bool = false {
        didSet {
            guard oldValue != readyToEditService else { return }
            onReadyToEditServiceChange?(readyToEditService)
        }
    }

    // MARK: Callback
    /// Called when the service is updated on the remote API succesfully.
    var onSuccess: (() -> Void)?
    /// Called when the new service name is already in use by another service.
    var onServiceNameInUse: (() -> Void)?
    /// Called when the view should be allowed to make an update request.
    /// E.g. when the user uploads an image OR changes the name OR both.
    var onReadyToEditServiceChange: ((Bool) -> Void)?

    // MARK: ImageDataContainingViewModel
    var imageData: ImageData? {
        didSet {
            updateReadyToEditService()
        }
    }

    // MARK: APIErrorProducing
    var onError: ((NotifireAPIError) -> Void)?

    // MARK: - Initialization
    init(sessionHandler: UserSessionHandler, service: LocalService) {
        self.sessionHandler = sessionHandler
        self.service = service
        super.init()
        afterValidation = { [weak self] valid in
            guard let `self` = self else { return }
            self.serviceNameValidated = valid && !self.editedServiceName.isEmpty
        }
    }

    // MARK: - Private
    private func updateReadyToEditService() {
        readyToEditService = serviceNameValidated || imageValidated
    }

    // MARK: - Methods
    func updateService() {
        guard readyToEditService, !loadingModel.isLoading, let localService = service.safeReference else { return }
        loadingModel.toggle()

        let completion: NotifireAPIBaseManager.Callback<ServiceUpdateResponse> = { [weak self] result in
            guard let `self` = self else { return }
            self.loadingModel.toggle()

            switch result {
            case .error(let error):
                self.onError?(error)
            case .success(let response):
                if response.success {
                    self.onSuccess?()
                } else {
                    self.onServiceNameInUse?()
                }
            }
        }

        if let imageData = imageData {
            // Image Change
            if editedServiceName.isEmpty {
                sessionHandler.notifireProtectedApiManager.updateServiceWithImage(service: localService, imageData: imageData, completion: completion)
            } else {
                let body = ServiceUpdateRequestBody(
                    name: editedServiceName,
                    id: service.id,
                    levels: service.levels,
                    deleteImage: false
                )
                sessionHandler.notifireProtectedApiManager.updateServiceWithImage(updateRequestBody: body, imageData: imageData, completion: completion)
            }

        } else {
            // Name change
            if editedServiceName.isEmpty {
                sessionHandler.notifireProtectedApiManager.update(service: service, completion: completion)
            } else {
                let body = ServiceUpdateRequestBody(name: editedServiceName, id: service.id, levels: service.levels, deleteImage: false)
                sessionHandler.notifireProtectedApiManager.updateService(updateRequestBody: body, completion: completion)
            }
        }
    }
}

class ServiceEditViewController: VMViewController<ServiceEditViewModel>, APIErrorResponding, APIErrorPresenting {

    // MARK: - Properties
    /// Called when the user has edited the service name or the service image but wants to cancel the edit process.
    /// Should show an alert confirming his decision to cancel.
    var onShouldCloseServiceEdit: (() -> Void)?
    /// Called when the user confirms 'Cancel' press or when the edit is successful.
    var onCloseServiceEdit: (() -> Void)?
    /// Called when the user wants to add a new image.
    var onImageAddPress: (() -> Void)?

    // MARK: UI
    lazy var imageView: RoundedEditableImageView = {
        let view = RoundedEditableImageView(image: nil)
        view.imageEditStyle = .edit
        view.onUserAction = { [unowned self] in
            self.onImageAddPress?()
        }
        if let imageURL = viewModel.service.imageURL {
            view.roundedImageView.sd_setImage(with: imageURL, placeholderImage: LocalService.defaultImage, options: [], completed: nil)
        } else {
            view.image = LocalService.defaultImage
        }
        return view
    }()

    lazy var editedServiceNameInput: ValidatableTextInput = {
        let textField = BottomBarTextField()
        textField.setPlaceholder(text: "New service name")
        let input = ValidatableTextInput(textField: textField, neutralStateValid: true)
        input.rules = ComponentRule.serviceNameRules
        input.validatingViewModelBinder = ValidatingViewModelBinder(viewModel: viewModel, for: \.editedServiceName)
        return input
    }()

    lazy var serviceNameLabel: UILabel = {
        let label = UILabel(style: .informationHeader)
        label.text = "Service name"
        label.numberOfLines = 1
        return label
    }()

    // MARK: NavBar buttons
    lazy var saveBarButton: UIBarButtonItem = {
        let saveButton = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(didSelectSaveEdit))
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
        setupTitleLabel()
        view.backgroundColor = .compatibleSystemBackground

        setupSubviews()

        // Navbar buttons
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(didSelectCancel))
        updateRightBarButtonItem(animated: false)

        // ViewModel
        prepareViewModel()
    }

    // MARK: - Private
    private func setupTitleLabel() {
        let navigationLabel = UILabel()
        let navigationTitle = NSMutableAttributedString(string: "Edit ", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14),
                                                                                      NSAttributedString.Key.foregroundColor: UIColor.compatibleSecondaryLabel])
        let serviceName = viewModel.service.safeReference?.name ?? "service"
        navigationTitle.append(NSMutableAttributedString(string: serviceName, attributes: TextAttributes.navigationTitle))
        navigationLabel.attributedText = navigationTitle
        navigationItem.titleView = navigationLabel
    }

    private func setupSubviews() {
        view.add(subview: imageView)
        imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        imageView.widthAnchor.constraint(equalToConstant: Size.Image.largeService).isActive = true
        imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor).isActive = true
        imageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: Size.componentSpacing).isActive = true

        let separator = HairlineView()
        view.add(subview: separator)
        separator.embedSides(in: view)
        separator.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: Size.componentSpacing).isActive = true

        view.add(subview: serviceNameLabel)
        serviceNameLabel.setContentHuggingPriority(.init(1000), for: .horizontal)
        serviceNameLabel.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor).isActive = true
        serviceNameLabel.topAnchor.constraint(equalTo: separator.bottomAnchor, constant: Size.componentSpacing).isActive = true

        view.add(subview: editedServiceNameInput)
        editedServiceNameInput.textField.setContentCompressionResistancePriority(.init(1000), for: .horizontal)
        editedServiceNameInput.textField.firstBaselineAnchor.constraint(equalTo: serviceNameLabel.firstBaselineAnchor).isActive = true
        editedServiceNameInput.leadingAnchor.constraint(equalTo: serviceNameLabel.trailingAnchor, constant: Size.standardMargin).isActive = true
        editedServiceNameInput.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor).isActive = true
    }

    private func prepareViewModel() {
        viewModel.createComponentValidator(with: [editedServiceNameInput])

        viewModel.onReadyToEditServiceChange = { [weak self] success in
            self?.saveBarButton.isEnabled = success
        }

        viewModel.onSuccess = { [weak self] in
            self?.onCloseServiceEdit?()
        }

        viewModel.loadingModel.onLoadingChange = { [weak self] loading in
            self?.editedServiceNameInput.textField.isEnabled = !loading
            self?.navigationItem.leftBarButtonItem?.isEnabled = !loading
            self?.imageView.isUserInteractionEnabled = !loading
            self?.updateRightBarButtonItem()
        }

        setViewModelOnError()
    }

    private func updateRightBarButtonItem(animated: Bool = true) {
        if viewModel.loadingModel.isLoading {
            navigationItem.setRightBarButton(spinnerBarButton, animated: animated)
        } else {
            navigationItem.setRightBarButton(saveBarButton, animated: animated)
        }
    }

    // MARK: Event Handlers
    @objc private func didSelectSaveEdit() {
        viewModel.updateService()
    }

    @objc private func didSelectCancel() {
        if viewModel.readyToEditService {
            onShouldCloseServiceEdit?()
        } else {
            onCloseServiceEdit?()
        }
    }

    func update(image: UIImage, format imageFormat: ServiceImagePicker.ImageFormat) {
        do {
            // Create PNG
            try viewModel.setNewImageData(from: image, format: imageFormat)
            imageView.image = image
        } catch {
            // Formatting failed
            Logger.log(.error, "\(self) unable to create image data for this image (format=\(imageFormat.rawValue))")
            let alertVC = NotifireAlertViewController(alertTitle: "Image upload error", alertText: "Formatting of this image failed. Please use another one.", alertStyle: .fail)
            alertVC.add(action: NotifireAlertAction(title: "Ok", style: .neutral, handler: { _ in
                alertVC.dismiss(animated: true, completion: nil)
            }))
            present(alertVC, animated: true, completion: nil)
        }
    }
}

class ServiceEditCoordinator: ChildCoordinator, PresentingCoordinator, OKAlertPresenting, OKCancelAlertPresenting {

    // MARK: - Properties
    let serviceEditController: ServiceEditViewController

    // MARK: ChildCoordinator
    var viewController: UIViewController {
        return serviceEditController
    }

    // MARK: ImagePickerPresenting
    var presentationViewFrame: CGRect {
        // FIXME: imageview
        return serviceEditController.view.frame
    }
    var presentedCoordinator: ChildCoordinator?
    var presentationDismissHandler: UIAdaptivePresentationDismissHandler?

    var serviceImagePicker: ServiceImagePicker?

    // MARK: - Initialization
    init(serviceEditController: ServiceEditViewController) {
        self.serviceEditController = serviceEditController
    }

    // MARK: - Coordinator
    func start() {
        serviceEditController.onImageAddPress = { [weak self] in
            self?.showImagePicker()
        }

        serviceEditController.onShouldCloseServiceEdit = { [weak self] in
            self?.presentOKCancelAlert(
                title: "You have unsaved edits",
                message: "Do you really want to discard your changes to this service?",
                preferredStyle: .alert,
                okTitle: "Yes",
                cancelTitle: "No",
                onOK: { [weak self] in
                    self?.serviceEditController.onCloseServiceEdit?()
                },
                onCancel: nil
            )
        }

        serviceEditController.viewModel.onServiceNameInUse = { [weak self] in
            self?.presentOKAlert(title: "This service name is already in use.", message: "Please try again with another name.", preferredStyle: .alert)
        }
    }

    func showImagePicker() {
        let imagePicker = ServiceImagePicker(presenter: self)
        imagePicker.completion = { [weak self] result in
            switch result {
            case .selected(let image, let format):
                self?.serviceEditController.update(image: image, format: format)
            case .cancelled:
                break
            }
        }
        let view = serviceEditController.view
        let imageFrame = view?.convert(serviceEditController.imageView.frame, to: view)
        imagePicker.pickImage(imageFrame: imageFrame)
        serviceImagePicker = imagePicker
    }
}

class ServiceCoordinator: ChildCoordinator, NavigatingChildCoordinator, PresentingCoordinator {

    // MARK: - Properties
    let serviceViewController: ServiceViewController

    weak var parentNavigatingCoordinator: NavigatingCoordinator?

    var viewController: UIViewController {
        return serviceViewController
    }

    // MARK: PresentingCoordinator
    var presentedCoordinator: ChildCoordinator?
    var presentationDismissHandler: UIAdaptivePresentationDismissHandler?

    // MARK: - Initialization
    init(serviceViewController: ServiceViewController) {
        self.serviceViewController = serviceViewController
    }

    // MARK: - Methods
    func start() {
        serviceViewController.delegate = self
    }

    func showNotifications(localService: LocalService) {
        showNotifications(serviceID: localService.id)
    }

    @discardableResult
    func showNotifications(serviceID: Int, animated: Bool = true) -> NotificationsCoordinator {
        let realmProvider = serviceViewController.viewModel.userSessionHandler
        let serviceNotificationsViewModel = ServiceNotificationsViewModel(realmProvider: realmProvider, serviceID: serviceID, userSession: realmProvider.userSession)
        let notificationsCoordinator = NotificationsCoordinator(notificationsViewModel: serviceNotificationsViewModel)
        parentNavigatingCoordinator?.push(childCoordinator: notificationsCoordinator, animated: animated)
        return notificationsCoordinator
    }

    func showServiceEdit(localService: LocalService) {
        let serviceEditViewModel = ServiceEditViewModel(sessionHandler: serviceViewController.viewModel.userSessionHandler, service: localService)
        let serviceEditVC = ServiceEditViewController(viewModel: serviceEditViewModel)
        serviceEditVC.onCloseServiceEdit = { [weak self] in
            self?.dismissPresentedCoordinator(animated: true)
        }
        let serviceEditCoordinator = ServiceEditCoordinator(serviceEditController: serviceEditVC)
        let navigationController = NotifireNavigationController()
        navigationController.navigationBarTintColor = .primary
        let serviceEditNavigationCoordinator = NavigationCoordinator(rootChildCoordinator: serviceEditCoordinator, navigationController: navigationController)
        present(childCoordinator: serviceEditNavigationCoordinator, animated: true, modalPresentationStyle: .fullScreen)
    }
}

extension ServiceCoordinator: ServiceViewControllerDelegate {
    func shouldShowNotifications(for service: LocalService) {
        showNotifications(localService: service)
    }

    func shouldDismissServiceViewController() {
        parentNavigatingCoordinator?.popChildCoordinator()
    }

    func shouldPresentEditServiceView(for service: LocalService) {
        showServiceEdit(localService: service)
    }
}
