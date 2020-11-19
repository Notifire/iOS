//
//  AppCoordinator+DeeplinkedVMViewControllerDelegate.swift
//  Notifire
//
//  Created by David Bielik on 02/09/2020.
//  Copyright © 2020 David Bielik. All rights reserved.
//

import Foundation

extension AppCoordinator: DeeplinkedVMViewControllerDelegate {
    func shouldCloseDeeplink() {
        deeplinkHandler.finishDeeplink()
    }
}
