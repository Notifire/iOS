//
//  AppCoordinator+ConfirmEmailViewControllerDelegate.swift
//  Notifire
//
//  Created by David Bielik on 02/09/2020.
//  Copyright © 2020 David Bielik. All rights reserved.
//

import Foundation

extension AppCoordinator: ConfirmEmailViewControllerDelegate {
    func didFinishEmailConfirmation() {
        deeplinkHandler.finishDeeplink()
    }
}
