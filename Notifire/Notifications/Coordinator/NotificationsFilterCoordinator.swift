//
//  NotificationsFilterCoordinator.swift
//  Notifire
//
//  Created by David Bielik on 12/02/2021.
//  Copyright © 2021 David Bielik. All rights reserved.
//

import UIKit

class NotificationsFilterCoordinator: NavigatingChildCoordinator {
    // MARK: - Properties
    let notificationsFilterViewController: NotificationsFilterViewController

    // MARK: NavigatingChildCoordinator
    weak var parentNavigatingCoordinator: NavigatingCoordinator?

    // MARK: TabbedCoordinator
    var viewController: UIViewController {
        return notificationsFilterViewController
    }

    // MARK: - Initialization
    init(notificationsFilterViewController: NotificationsFilterViewController) {
        self.notificationsFilterViewController = notificationsFilterViewController
    }

    // MARK: - Coordinator
    func start() {
        notificationsFilterViewController.onTimeframeSelectionPressed = { [weak self] in
            self?.showTimeFrameSelection()
        }
    }

    func showTimeFrameSelection() {
        let viewModel = TimeframeSelectionViewModel(filterVM: notificationsFilterViewController.viewModel)
        let viewController = TimeframeSelectionViewController(viewModel: viewModel)
        let genericCoordinator = GenericCoordinator(viewController: viewController)
        parentNavigatingCoordinator?.push(childCoordinator: genericCoordinator, animated: true)
    }
}
