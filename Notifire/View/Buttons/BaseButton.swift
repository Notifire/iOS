//
//  BaseButton.swift
//  Notifire
//
//  Created by David Bielik on 27/08/2018.
//  Copyright © 2018 David Bielik. All rights reserved.
//

import UIKit

class BaseButton: UIButton {

    // MARK: - Inherited
    override init(frame: CGRect) {
        super.init(frame: frame)
        privateSetup()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        privateSetup()
    }

    // MARK: - Private
    private func privateSetup() {
        translatesAutoresizingMaskIntoConstraints = false
        addTargets()
        setup()
    }

    // MARK: - Open
    open func addTargets() {
        addTarget(self, action: #selector(touchUpInside), for: .touchUpInside)
    }

    open func setup() {

    }

    // MARK: - Event Handlers
    @objc func touchUpInside() {
        self.onProperTap?()
    }

    // MARK: - Public
    public var onProperTap: (() -> Void)?
}
