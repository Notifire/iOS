//
//  ChangePasswordCoordinator.swift
//  Notifire
//
//  Created by David Bielik on 17/11/2020.
//  Copyright © 2020 David Bielik. All rights reserved.
//

import Foundation

class ChangePasswordCoordinator: GenericSuccessCoordinator<ChangePasswordViewController> {

    // MARK: - Properties

    // MARK: Inherited
    override func dismissAfterSuccessOk() {
        parentNavigatingCoordinator?.popChildCoordinator()
    }
}
