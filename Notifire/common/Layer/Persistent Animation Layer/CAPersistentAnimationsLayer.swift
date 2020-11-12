//
//  CAPersistentAnimationsLayer.swift
//  Notifire
//
//  Created by David Bielik on 31/08/2018.
//  Copyright © 2018 David Bielik. All rights reserved.
//

import UIKit

class CAPersistentAnimationsLayer: BaseLayer, PersistentAnimationsObserving {

    // MARK: - Properties
    var observers = [NSObjectProtocol]()
    var persistentAnimations: [String: CAAnimation] = [:]
    var persistentSpeed: Float = 0.0

    // MARK: - Inherited
    override func setupSublayers() {
        startObservingNotifications()
    }

    deinit {
        stopObservingNotifications()
    }
}
