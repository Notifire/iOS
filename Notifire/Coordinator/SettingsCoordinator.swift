//
//  SettingsCoordinator.swift
//  Notifire
//
//  Created by David Bielik on 12/10/2018.
//  Copyright © 2018 David Bielik. All rights reserved.
//

import UIKit

class SettingsCoordinator: NavigatingChildCoordinator {

    // MARK: - Properties
    let settingsViewController: SettingsViewController

    // MARK: NavigatingChildCoordinator
    weak var parentNavigatingCoordinator: NavigatingCoordinator?

    // MARK: TabbedCoordinator
    var viewController: UIViewController {
        return settingsViewController
    }

    // MARK: - Initialization
    init(settingsViewController: SettingsViewController) {
        self.settingsViewController = settingsViewController
    }

    func start() {

    }
}
