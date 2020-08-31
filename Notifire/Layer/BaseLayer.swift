//
//  BaseLayer.swift
//  Notifire
//
//  Created by David Bielik on 01/09/2018.
//  Copyright © 2018 David Bielik. All rights reserved.
//

import UIKit

class BaseLayer: CALayer {
    
    // MARK: - Inherited
    override init() {
        super.init()
        setupSublayers()
    }
    
    override init(layer: Any) {
        super.init(layer: layer)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupSublayers()
    }
    
    // MARK: - Open
    open func setupSublayers() {
        
    }
}
