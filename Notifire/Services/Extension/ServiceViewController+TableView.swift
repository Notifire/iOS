//
//  ServiceViewController+TableView.swift
//  Notifire
//
//  Created by David Bielik on 15/10/2020.
//  Copyright © 2020 David Bielik. All rights reserved.
//

import UIKit

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
                guard let cell = tableView.dequeue(reusableCell: ServiceAPIKeyTableViewCell.self, for: indexPath) else { return UITableViewCell() }
                if viewModel.isKeyVisible {
                    cell.serviceKey = viewModel.currentLocalService?.serviceAPIKey
                } else {
                    cell.serviceKey = nil
                }
                cell.delegate = self
                return cell
            } else {
                guard let cell = tableView.dequeue(reusableCell: ServiceTableViewCell.self, for: indexPath) else { return UITableViewCell() }
                cell.textLabel?.text = "Generate a new service key"
                cell.textLabel?.set(style: .notifirePositive)
                return cell
            }

        case 2, 3:
            guard let cell = tableView.dequeue(reusableCell: ServiceTableViewCell.self, for: indexPath) else { return UITableViewCell() }
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
            let notifireAlertVC = NotifireAlertViewController(alertTitle: "Are you sure?", alertText: "Generating a new API key will invalidate your current one. Confirm your decision by entering your password in the form below.")
            let confirmAction = NotifireAlertAction(title: "Confirm", style: .positive, handler: { _ in
                notifireAlertVC.dismiss(animated: true, completion: {
                    self.viewModel.generateNewAPIKey { result in
                        let newAlert = NotifireAlertViewController(alertTitle: nil, alertText: nil)
                        newAlert.add(action: NotifireAlertAction(title: "OK", style: .positive, handler: { _ in
                            newAlert.dismiss(animated: true, completion: nil)
                        }))
                        switch result {
                        case .success:
                            newAlert.alertTitle = "Success!"
                            newAlert.alertText = "Don't forget to swap your old API key for a new one in your clients!"
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
            present(alert: notifireAlertVC, animated: true, completion: nil)
        } else if indexPath.section == 2 {
            guard let localService = viewModel.currentLocalService?.safeReference else { return }
            let notifireAlertVC = NotifireAlertViewController(
                alertTitle: "Delete all notifications for \(localService.name)?",
                alertText: "CAUTION: this action is irreversible. Your notifications are saved only on the device that received them.",
                alertStyle: .none
            )
            notifireAlertVC.add(action: NotifireAlertAction(title: "Yes", style: .positive, handler: { _ in
                notifireAlertVC.dismiss(animated: true, completion: { [weak self] in
                    guard let `self` = self, let localService = localService.safeReference else { return }
                    let deleted = self.viewModel.deleteServiceNotifications()
                    let afterDeletionAlert = NotifireAlertViewController(
                        alertTitle: deleted ? "Success!" : "Something went wrong.",
                        alertText: deleted ? "Notifications for \(localService.name) were deleted." : "Restart the application and try again.",
                        alertStyle: deleted ? .success : .fail)
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
            let notifireAlertVM = NotifireAlertViewModel(apiManager: NotifireAPIFactory.createAPIManager())
            let notifireAlertVC = NotifireInputAlertViewController(alertTitle: "Are you sure?", alertText: "This operation is permanent and you will lose all service notifications!", viewModel: notifireAlertVM)
            let confirmAction = NotifireAlertAction(title: "Delete", style: .negative, handler: { _ in
                notifireAlertVC.dismiss(animated: true, completion: {
                    self.viewModel.deleteService()
                })
            })
            notifireAlertVC.add(action: confirmAction)
            notifireAlertVC.add(action: NotifireAlertAction(title: "Cancel", style: .neutral, handler: { _ in
                notifireAlertVC.dismiss(animated: true, completion: nil)
            }))
            present(alert: notifireAlertVC, animated: true, completion: nil)
        }
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let yPos = parentScrollView.contentOffset.y + parentScrollView.adjustedContentInset.top
        let buttonY = view.convert(CGPoint.zero, from: notificationsHeaderView.notificationsButton).y

        // sticky ServiceHeaderView (image)
        if yPos >= 0 {
            serviceHeaderView.floatingTopToTopConstraint.constant = yPos
        } else {
            // fix for the serviceHeaderView not getting layed out after scrolling too fast
            serviceHeaderView.floatingTopToTopConstraint.constant = 0
        }

        // sticky ServiceNotificationsHeaderView
        let shouldStickNotificationsHeaderView = yPos >= notificationsHeaderView.frame.origin.y
        if shouldStickNotificationsHeaderView {
            let headerViewTopY = yPos - notificationsHeaderView.frame.origin.y
            notificationsHeaderView.floatingTopToTopConstraint.constant = headerViewTopY
            let maskViewY = headerViewTopY - notificationsHeaderView.bounds.height/2
            tableViewMaskView.frame = CGRect(origin: CGPoint(x: 0, y: maskViewY), size: CGSize(width: tableView.bounds.width, height: tableView.bounds.height-maskViewY))
        } else {
            notificationsHeaderView.floatingTopToTopConstraint.constant = 0
            tableViewMaskView.frame = tableView.bounds
        }
        notificationsHeaderView.gradientVisible = shouldStickNotificationsHeaderView

        // titleLabel transition
        let labelY = view.convert(CGPoint.zero, from: serviceHeaderView.serviceNameLabel).y
        let labelHeight = serviceHeaderView.serviceNameLabel.bounds.height
        let buttonYOffset: CGFloat = 8
        let alphaStartHeight = 0.9 * labelHeight
        let titleButtonOverlap = min(max(0, buttonY + buttonYOffset - labelY), alphaStartHeight + buttonYOffset)
        let serviceNameUnreadableFractionComplete = 1 - (titleButtonOverlap / (alphaStartHeight + buttonYOffset))
        let shouldStartShowingTitleLabel = serviceNameUnreadableFractionComplete > 0
        if shouldStartShowingTitleLabel {
            titleLabel.transform = CGAffineTransform.identity.translatedBy(x: 0, y: 8 - 8 * serviceNameUnreadableFractionComplete)
            titleLabel.alpha = serviceNameUnreadableFractionComplete
        } else {
            titleLabel.transform = CGAffineTransform.identity
            titleLabel.alpha = 0
        }

        // ServiceHeaderView (image) transforms
        if yPos < 0 {
            // Expanding
            let imageWidth = serviceHeaderView.serviceImageView.bounds.width
            let maxScaledWidth = view.bounds.width - 2*Size.doubleMargin
            let maxScale = maxScaledWidth / imageWidth
            let scaleProgress = min(max(maxScaledWidth + yPos, 0), maxScaledWidth)
            let scaleFractionComplete = 1 - (scaleProgress / maxScaledWidth)
            let scale = 1 + (maxScale - 1) * scaleFractionComplete
            let yOffset = 1/scale * (-0.5)*imageWidth + imageWidth/2
            serviceHeaderView.serviceImageView.transform = CGAffineTransform(scaleX: scale, y: scale).translatedBy(x: 0, y: -yOffset)
            // Fix alpha for fast scrolling
            if serviceHeaderView.serviceImageView.alpha < 1 {
                serviceHeaderView.serviceImageView.alpha = 1
            }
        } else if yPos > 0 {
            // Shrinking
            let imageHeight = serviceHeaderView.serviceImageView.bounds.height
            let imageY = view.convert(CGPoint.zero, from: serviceHeaderView.serviceImageView).y
            let imageButtonOverlap = min(max(0, buttonY - 10 - 0.2 * imageHeight - imageY), 0.8*imageHeight)
            let serviceImageOverlapFractionComplete = 1 - (imageButtonOverlap / (0.8*imageHeight))
            let scale: CGFloat = 1 - 0.3 * serviceImageOverlapFractionComplete
            let yOffset = 1/scale * (-0.5)*imageHeight + imageHeight/2
            serviceHeaderView.serviceImageView.transform = CGAffineTransform(scaleX: scale, y: scale).translatedBy(x: 0, y: yOffset)
            serviceHeaderView.serviceImageView.alpha = 1 - serviceImageOverlapFractionComplete
        } else {
            // Still
            serviceHeaderView.serviceImageView.transform = .identity
            serviceHeaderView.serviceImageView.alpha = 1
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
