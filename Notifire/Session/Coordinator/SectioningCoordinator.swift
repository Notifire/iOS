//
//  SectioningCoordinator.swift
//  Notifire
//
//  Created by David Bielik on 07/09/2020.
//  Copyright © 2020 David Bielik. All rights reserved.
//

import UIKit

/// Represents a coordinator that contains other child coordinators organized into well-defined sections.
/// Used with TabBars and SegmentedControls.
protocol SectioningCoordinator: Coordinator {
    /// Require a type that can become a key in a dictionary. Enums are recommended to be used by conformers to this protocol.
    associatedtype SectionDefiningEnum: Hashable

    /// The currently active coordinator
    var activeCoordinator: SectionedCoordinator? { get set }
    /// The child coordinators
    var childCoordinators: [SectionDefiningEnum: SectionedCoordinator] { get set }
    /// The viewcontroller that will be the parent of the child coordinator viewcontrollers. This viewController contains a container view for the child VCs.
    var containerViewController: (UIViewController & ChildViewControllerContainerProviding) { get }

    /// This function should return a child coordinator depending on the section (enum case).
    func createChildCoordinatorFrom(section: SectionDefiningEnum) -> SectionedCoordinator
}

extension SectioningCoordinator {
    func changeSection(to section: SectionDefiningEnum) {
        let selectedCoordinator: TabbedCoordinator
        if let existingChildCoordinator = childCoordinators[section] {
            // coordinator instantiated previously
            selectedCoordinator = existingChildCoordinator
        } else {
            // create a new child coordinator in case it's the first time we see it
            let childCoordinator = createChildCoordinatorFrom(section: section)
            childCoordinators[section] = childCoordinator
            // and start it...
            childCoordinator.start()
            selectedCoordinator = childCoordinator
        }

        // Remove previously active coordinator's view controller if needed
        if let currentlyActiveCoordinator = activeCoordinator {
            let activeVC = currentlyActiveCoordinator.viewController
            containerViewController.remove(childViewController: activeVC)
        }
        // Set new active coordinator
        activeCoordinator = selectedCoordinator
        containerViewController.embed(viewController: selectedCoordinator.viewController)
    }
}
