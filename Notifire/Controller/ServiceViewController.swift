//
//  ServiceViewController.swift
//  Notifire
//
//  Created by David Bielik on 20/10/2018.
//  Copyright © 2018 David Bielik. All rights reserved.
//

import UIKit
import Photos

protocol ServiceViewControllerDelegate: class {
    func didDelete(service: LocalService)
    func shouldShowNotifications(for service: LocalService)
}

class ServiceViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate, NavigationBarDisplaying, NotifirePoppablePresenting {

    // MARK: - Properties
    let viewModel: ServiceViewModel
    weak var delegate: ServiceViewControllerDelegate?

    // MARK: Views
    let parentScrollView: UIScrollView = {
        let scroll = UIScrollView()
        scroll.alwaysBounceVertical = true
        scroll.showsVerticalScrollIndicator = false
        scroll.contentInsetAdjustmentBehavior = .always
        scroll.delaysContentTouches = false
        return scroll
    }()

    let titleLabel: UILabel = {
        let label = UILabel(style: .heavyTitle)
        label.alpha = 0
        return label
    }()

    let serviceHeaderView = ServiceHeaderView()

    lazy var notificationsHeaderView: ServiceNotificationsHeaderView = {
        let view = ServiceNotificationsHeaderView()
        view.notificationsButton.onProperTap = {
            self.delegate?.shouldShowNotifications(for: self.viewModel.localService)
        }
        return view
    }()

    lazy var tableView: DynamicTableView = {
        let table = DynamicTableView(frame: .zero, style: .grouped)
        table.dataSource = self
        table.delegate = self
        table.backgroundColor = .backgroundColor
        table.mask = tableViewMaskView
        table.register(UITableViewCell.self, forCellReuseIdentifier: "serviceTableViewCell")
        table.register(ServiceAPIKeyTableViewCell.self, forCellReuseIdentifier: ServiceAPIKeyTableViewCell.identifier)
        return table
    }()

    let tableViewMaskView: UIView = {
        let view = UIView()
        view.isUserInteractionEnabled = false
        view.backgroundColor = .blue
        return view
    }()

    var childScrollView: UIScrollView {
        return tableView
    }

    func levelCell(level: NotificationLevel, serviceLevelKeyPath: ReferenceWritableKeyPath<LocalService, Bool>) -> NotificationLevelTableViewCell {
        let cell = NotificationLevelTableViewCell()
        cell.model = NotificationLevelModel(level: level, enabled: viewModel.localService[keyPath: serviceLevelKeyPath])
        cell.onLevelChange = { enabled in
            self.viewModel.updateService {
                self.viewModel.localService[keyPath: serviceLevelKeyPath] = enabled
            }
        }
        return cell
    }

    lazy var infoCell = levelCell(level: .info, serviceLevelKeyPath: \.info)
    lazy var warningCell = levelCell(level: .warning, serviceLevelKeyPath: \.warning)
    lazy var errorCell = levelCell(level: .error, serviceLevelKeyPath: \.error)

    var gradientLayer: NotifireBackgroundLayer?

    // MARK: - Initialization
    init(viewModel: ServiceViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) { fatalError() }

    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .backgroundColor
        navigationController?.navigationBar.tintColor = .black
        removeNavigationItemBackButtonTitle()
        setupTitleView()
        prepareViewModel()
        layout()
        addScrollViewGradientLayer()
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "baseline_more_horiz_black_24pt"), style: .plain, target: self, action: #selector(didTapMoreOptions))
        updateUI()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateGradient()
        let y = parentScrollView.contentOffset.y + parentScrollView.adjustedContentInset.top
        let headerViewTopY = y - notificationsHeaderView.frame.origin.y
        let maskViewY = headerViewTopY - notificationsHeaderView.bounds.height/2
        tableViewMaskView.frame = CGRect(origin: CGPoint(x: 0, y: maskViewY), size: CGSize(width: tableView.bounds.width, height: tableView.bounds.height-maskViewY))

        // fix for serviceHeaderView not getting it's correct frame on the first layout pass
        serviceHeaderView.setNeedsLayout()
        serviceHeaderView.layoutIfNeeded()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        hideNavBar()
        navigationController?.navigationBar.backgroundColor = .clear
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // set the delegate after getting presented to the screen
        parentScrollView.delegate = self
    }

    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        guard presented is NotifirePoppable else { return nil }
        return NotifirePopAnimationController()
    }

    // MARK: - Private
    private func setupTitleView() {
        let titleLabelContainerView = UIView()
        titleLabelContainerView.translatesAutoresizingMaskIntoConstraints = false
        titleLabelContainerView.add(subview: titleLabel)
        titleLabel.embed(in: titleLabelContainerView)
        titleLabelContainerView.layoutIfNeeded()
        titleLabelContainerView.sizeToFit()
        titleLabelContainerView.translatesAutoresizingMaskIntoConstraints = true
        navigationItem.titleView = titleLabelContainerView
    }

    private func prepareViewModel() {
        viewModel.onServiceUpdate = { [weak self] service in
            self?.updateUI()
        }
        viewModel.onServiceDeletion = { [weak self] in
            guard let `self` = self else { return }
            self.delegate?.didDelete(service: self.viewModel.localService)
        }
    }

    private func layout() {
        view.add(subview: parentScrollView)
        parentScrollView.embed(in: view)

        let content = UIView()
        parentScrollView.add(subview: content)
        content.topAnchor.constraint(equalTo: parentScrollView.topAnchor).isActive = true
        content.leadingAnchor.constraint(equalTo: parentScrollView.leadingAnchor).isActive = true
        content.trailingAnchor.constraint(equalTo: parentScrollView.trailingAnchor).isActive = true
        // priorities for tableview scrolling to function properly
        let contentBottomToScrollBottom = content.bottomAnchor.constraint(equalTo: parentScrollView.bottomAnchor)
        contentBottomToScrollBottom.priority = UILayoutPriority(rawValue: 250)
        contentBottomToScrollBottom.isActive = true
        let contentYCenterToScrollViewYCenter = content.centerYAnchor.constraint(equalTo: parentScrollView.centerYAnchor)
        contentYCenterToScrollViewYCenter.priority = UILayoutPriority(rawValue: 250)
        contentYCenterToScrollViewYCenter.isActive = true
        content.centerXAnchor.constraint(equalTo: parentScrollView.centerXAnchor).isActive = true

        content.add(subview: serviceHeaderView)
        serviceHeaderView.topAnchor.constraint(equalTo: content.topAnchor).isActive = true
        serviceHeaderView.leadingAnchor.constraint(equalTo: content.leadingAnchor).isActive = true
        serviceHeaderView.trailingAnchor.constraint(equalTo: content.trailingAnchor).isActive = true

        content.add(subview: tableView)
        tableView.leadingAnchor.constraint(equalTo: content.leadingAnchor).isActive = true
        tableView.trailingAnchor.constraint(equalTo: content.trailingAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: content.bottomAnchor).isActive = true

        content.add(subview: notificationsHeaderView)
        notificationsHeaderView.leadingAnchor.constraint(equalTo: content.leadingAnchor).isActive = true
        notificationsHeaderView.trailingAnchor.constraint(equalTo: content.trailingAnchor).isActive = true
        notificationsHeaderView.centerYAnchor.constraint(equalTo: serviceHeaderView.bottomAnchor).isActive = true
        notificationsHeaderView.bottomAnchor.constraint(equalTo: tableView.topAnchor).isActive = true
    }

    private func addScrollViewGradientLayer() {
        guard gradientLayer == nil else { return }
        let gradient = NotifireBackgroundLayer()
        view.layer.insertSublayer(gradient, at: 0)
        gradientLayer = gradient
    }

    private func updateUI() {
        let service = viewModel.localService
        titleLabel.text = service.name
        serviceHeaderView.service = service
        infoCell.levelSwitch.setOn(service.info, animated: true)
        warningCell.levelSwitch.setOn(service.warning, animated: true)
        errorCell.levelSwitch.setOn(service.error, animated: true)
        tableView.reloadRows(at: [IndexPath(row: 0, section: 1)], with: .fade)
    }

    // MARK: Event Handlers
    @objc private func didTapMoreOptions() {
        let options = UIAlertController(title: "", message: "Service options", preferredStyle: .actionSheet)
        options.addAction(UIAlertAction(title: "Change service image", style: .default, handler: { _ in

        }))
        options.addAction(UIAlertAction(title: "Set default image", style: .default, handler: { _ in

        }))
        options.addAction(UIAlertAction(title: "Rename this service", style: .default, handler: { _ in

        }))
        options.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { _ in
            options.dismiss(animated: true, completion: nil)
        }))
        present(options, animated: true, completion: nil)
    }
}

extension ServiceViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0: return 3
        case 1: return 2
        case 2, 3: return 1
        default: return 0
        }
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 4
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            switch indexPath.row {
            case 0:
                return infoCell
            case 1:
                return warningCell
            default:
                return errorCell
            }
        case 1:
            if indexPath.row == 0 {
                guard let cell = tableView.dequeueReusableCell(withIdentifier: ServiceAPIKeyTableViewCell.identifier) as? ServiceAPIKeyTableViewCell else { return UITableViewCell() }
                if viewModel.isKeyVisible {
                    cell.serviceKey = viewModel.localService.serviceKey
                } else {
                    cell.serviceKey = nil
                }
                cell.delegate = self
                return cell
            } else {
                guard let cell = tableView.dequeueReusableCell(withIdentifier: "serviceTableViewCell") else {
                    return UITableViewCell()
                }
                cell.textLabel?.text = "Generate a new service key"
                cell.textLabel?.set(style: .notifirePositive)
                return cell
            }

        case 2, 3:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "serviceTableViewCell") else {
                return UITableViewCell()
            }
            if indexPath.section == 2 {
                cell.textLabel?.text = "Delete notifications"
                cell.textLabel?.set(style: .negative)
            } else {
                cell.textLabel?.text = "Delete service"
                cell.textLabel?.set(style: .negativeMedium)
            }
            return cell
        default:
            return UITableViewCell()
        }
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 1 && indexPath.row == 0 {
            return UITableView.automaticDimension
        }
        return Size.Cell.height
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return "Notification levels"
        case 1:
            return "Service key"
        default:
            return ""
        }
    }

    func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        switch section {
        case 0:
            return "Enable or disable notification levels you wish to receive for this service. These settings are shared between your devices."
        case 1:
            return "Service key is necessary for sending notifications. Copy it into your clipboard for further usage in your NotifireClient of choice. Or generate a new one in case the current key gets compromised."
        case 2:
            return "This action will delete all local notification data associated with this service."
        default:
            return ""
        }
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 2 {
            return Size.Cell.height * 2
        }
        return UIView.noIntrinsicMetric
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 2 {
            return UIView()
        }
        return nil
    }
}

extension ServiceViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        if indexPath.section == 0 || (indexPath.section == 1 && indexPath.row == 0) {
            return false
        } else {
            return true
        }
    }

    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        if indexPath.section == 0 || (indexPath.section == 1 && indexPath.row == 0) {
            return nil
        } else {
            return indexPath
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.section == 1 && indexPath.row == 1 {
            let notifireAlertVM = NotifireAlertViewModel(notifireApiManager: NotifireAPIManagerFactory.createAPIManager())
            let notifireAlertVC = NotifireInputAlertViewController(alertTitle: "Are you sure?", alertText: "Generating a new API key will invalidate your current one. Confirm your decision by entering your password in the form below.", viewModel: notifireAlertVM)
            let confirmAction = NotifireAlertAction(title: "Confirm", style: .positive, handler: { _ in
                notifireAlertVC.dismiss(animated: true, completion: {
                    self.viewModel.generateNewAPIKey(password: notifireAlertVM.textFieldText) { result in
                        let newAlert = NotifireAlertViewController(alertTitle: nil, alertText: nil)
                        newAlert.add(action: NotifireAlertAction(title: "OK", style: .positive, handler: { _ in
                            newAlert.dismiss(animated: true, completion: nil)
                        }))
                        switch result {
                        case .success:
                            newAlert.alertTitle = "Success!"
                            newAlert.alertText = "Don't forget to swap your old API key for a new one in your services!"
                        case .wrongPassword:
                            newAlert.alertTitle = "API Key generation has failed."
                            newAlert.alertText = "The password you've entered was incorrect."
                        }
                        self.present(alert: newAlert, animated: true, completion: nil)
                    }
                })
            })
            notifireAlertVC.add(action: confirmAction)
            notifireAlertVC.add(action: NotifireAlertAction(title: "Cancel", style: .neutral, handler: { _ in
                notifireAlertVC.dismiss(animated: true, completion: nil)
            }))
            notifireAlertVC.createValidatableInput(title: "Password", secure: true, rules: ComponentRule.passwordRules, validatingAction: confirmAction)
            present(alert: notifireAlertVC, animated: true, completion: nil)
        } else if indexPath.section == 2 {
            let notifireAlertVM = NotifireAlertViewModel(notifireApiManager: NotifireAPIManagerFactory.createAPIManager())
            let notifireAlertVC = NotifireInputAlertViewController(alertTitle: "Delete all notifications for \(viewModel.localService.name)?", alertText: "CAUTION: this action is irreversible. Your notifications are saved only on the device that received them.", viewModel: notifireAlertVM)
                notifireAlertVC.add(action: NotifireAlertAction(title: "Yes", style: .positive, handler: { _ in
                    notifireAlertVC.dismiss(animated: true, completion: { [weak self] in
                        guard let `self` = self else { return }
                        let deleted = self.viewModel.deleteServiceNotifications()
                        let afterDeletionAlert = NotifireAlertViewController(alertTitle: deleted ? "Success!" : "Something went wrong.", alertText: deleted ? "Notifications for \(self.viewModel.localService.name) were deleted." : "Restart the application and try again.")
                        afterDeletionAlert.add(action: NotifireAlertAction(title: "Ok", style: .neutral, handler: { _ in
                            afterDeletionAlert.dismiss(animated: true, completion: nil)
                        }))
                        self.present(alert: afterDeletionAlert, animated: true, completion: nil)
                    })
                }))
            notifireAlertVC.add(action: NotifireAlertAction(title: "No", style: .neutral, handler: { _ in
                notifireAlertVC.dismiss(animated: true, completion: nil)
            }))
            present(alert: notifireAlertVC, animated: true, completion: nil)
        } else if indexPath.section == 3 {
            let notifireAlertVM = NotifireAlertViewModel(notifireApiManager: NotifireAPIManagerFactory.createAPIManager())
            let notifireAlertVC = NotifireInputAlertViewController(alertTitle: "Are you sure?", alertText: "Confirm your decision by entering the service name below.", viewModel: notifireAlertVM)
            let confirmAction = NotifireAlertAction(title: "Delete", style: .negative, handler: { _ in
                notifireAlertVC.dismiss(animated: true, completion: {
                    self.viewModel.deleteService()
                })
            })
            notifireAlertVC.add(action: confirmAction)
            notifireAlertVC.add(action: NotifireAlertAction(title: "Cancel", style: .neutral, handler: { _ in
                notifireAlertVC.dismiss(animated: true, completion: nil)
            }))
            notifireAlertVC.createValidatableInput(title: "Service", secure: false, rules: [ComponentRule(kind: .equalToString(viewModel.localService.name), showIfBroken: false)], validatingAction: confirmAction)
            present(alert: notifireAlertVC, animated: true, completion: nil)
        }
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let y = parentScrollView.contentOffset.y + parentScrollView.adjustedContentInset.top
        // sticky ServiceHeaderView
        if y >= 0 {
            serviceHeaderView.floatingTopToTopConstraint.constant = y
        } else {
            // fix for the serviceHeaderView not getting layed out after scrolling too fast
            serviceHeaderView.floatingTopToTopConstraint.constant = 0
        }

        // sticky ServiceNotificationsHeaderView
        let shouldStickNotificationsHeaderView = y >= notificationsHeaderView.frame.origin.y
        if shouldStickNotificationsHeaderView {
            let headerViewTopY = y - notificationsHeaderView.frame.origin.y
            notificationsHeaderView.floatingTopToTopConstraint.constant = headerViewTopY
            let maskViewY = headerViewTopY - notificationsHeaderView.bounds.height/2
            tableViewMaskView.frame = CGRect(origin: CGPoint(x: 0, y: maskViewY), size: CGSize(width: tableView.bounds.width, height: tableView.bounds.height-maskViewY))
        } else {
            notificationsHeaderView.floatingTopToTopConstraint.constant = 0
            tableViewMaskView.frame = tableView.bounds
        }
        notificationsHeaderView.gradientVisible = shouldStickNotificationsHeaderView

        // titleLabel displaying
        let buttonY = view.convert(CGPoint.zero, from: notificationsHeaderView.notificationsButton).y
        let labelY = view.convert(CGPoint.zero, from: serviceHeaderView.serviceNameLabel).y
        let labelHeight = serviceHeaderView.serviceNameLabel.bounds.height
        let alphaStartHeight = labelHeight/2
        let overlap = min(max(0, buttonY - labelY), alphaStartHeight)
        let serviceNameUnreadableFractionComplete = 1 - (overlap / alphaStartHeight)
        let shouldStartShowingTitleLabel = serviceNameUnreadableFractionComplete > 0
        if shouldStartShowingTitleLabel {
            titleLabel.alpha = 0.2 + 0.8 * serviceNameUnreadableFractionComplete
        } else {
            titleLabel.alpha = 0
        }

        // gradient
        updateGradient()
    }

    func updateGradient() {
        let newGradientHeight = notificationsHeaderView.frame.origin.y-parentScrollView.contentOffset.y
        if newGradientHeight >= parentScrollView.adjustedContentInset.top {
            gradientLayer?.setFrameWithoutAnimation(CGRect(origin: .zero, size: CGSize(width: view.bounds.width, height: newGradientHeight)))
        } else {
            gradientLayer?.setFrameWithoutAnimation(CGRect(origin: .zero, size: CGSize(width: view.bounds.width, height: parentScrollView.adjustedContentInset.top)))
        }
    }
}

extension ServiceViewController: ServiceAPIKeyCellDelegate {
    func shouldReloadServiceCell() {
        viewModel.isKeyVisible = !viewModel.isKeyVisible
        tableView.reloadRows(at: [IndexPath(row: 0, section: 1)], with: .fade)
    }
}

extension ServiceViewController: ScrollReselectable {
    var scrollView: UIScrollView {
        return parentScrollView
    }

    var topContentOffset: CGPoint {
        return CGPoint(x: 0, y: -parentScrollView.adjustedContentInset.top)
    }
}
