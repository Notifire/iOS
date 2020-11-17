//
//  ChangePasswordCoordinator.swift
//  Notifire
//
//  Created by David Bielik on 17/11/2020.
//  Copyright © 2020 David Bielik. All rights reserved.
//

import Foundation

class ChangePasswordCoordinator: GenericSuccessCoordinator<ChangePasswordViewController>, NavigatingChildCoordinator {

    // MARK: - Properties
    // MARK: NavigatingChildCoordinator
    var parentNavigatingCoordinator: NavigatingCoordinator?

    // MARK: Inherited
    override func dismissAfterSuccessOk() {
        parentNavigatingCoordinator?.popChildCoordinator()
    }
}
