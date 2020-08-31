//
//  CAPersistentAnimationsShapeLayer.swift
//  Notifire
//
//  Created by David Bielik on 05/09/2018.
//  Copyright © 2018 David Bielik. All rights reserved.
//

import UIKit

class CAPersistentAnimationsShapeLayer: CAShapeLayer, PersistentAnimationsObserving {
    // MARK: - Properties
    var observers = [NSObjectProtocol]()
    var persistentAnimations: [String: CAAnimation] = [:]
    var persistentSpeed: Float = 0.0
    
    // MARK: - Inherited
    override init() {
        super.init()
        setupSublayers()
    }
    
    override init(layer: Any) {
        super.init(layer: layer)
        setupSublayers()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupSublayers()
    }
    
    override func hitTest(_ p: CGPoint) -> CALayer? {
        return super.hitTest(p)
    }
    
    deinit {
        removeObservers()
    }
    
    // MARK: - Private
    private func setupSublayers() {
        setupObservers()
    }
}
