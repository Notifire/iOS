//
//  LoginRegisterSplitterViewControllerDelegate.swift
//  Notifire
//
//  Created by David Bielik on 03/09/2020.
//  Copyright © 2020 David Bielik. All rights reserved.
//

import Foundation

protocol LoginRegisterSplitterViewControllerDelegate: NotifireUserSessionCreationDelegate {
    func shouldStartLoginFlow()
    func shouldStartManualRegisterFlow()
}
