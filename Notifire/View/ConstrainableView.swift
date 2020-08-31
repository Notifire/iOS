//
//  ConstrainableView.swift
//  Notifire
//
//  Created by David Bielik on 26/08/2018.
//  Copyright © 2018 David Bielik. All rights reserved.
//

import UIKit

class ConstrainableView: UIView {
    
    // MARK: - Inherited
    init() {
        super.init(frame: .zero)
        setup()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    // MARK: - Private
    private func setup() {
        translatesAutoresizingMaskIntoConstraints = false
        setupSubviews()
    }
    
    // MARK: - Open
    /// Override this function if you want to provide custom view logic (layout). Called after initialization. Default implementation does nothing.
    open func setupSubviews() {
        
    }
}
