//
//  DeeplinkedVMViewControllerDelegate.swift
//  Notifire
//
//  Created by David Bielik on 19/11/2020.
//  Copyright © 2020 David Bielik. All rights reserved.
//

import Foundation

protocol DeeplinkedVMViewControllerDelegate: class {
    /// Called when the deeplink VC should be closed / dismissed.
    func shouldCloseDeeplink()
}
