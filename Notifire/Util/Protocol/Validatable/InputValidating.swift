//
//  InputValidating.swift
//  Notifire
//
//  Created by David Bielik on 06/09/2018.
//  Copyright © 2018 David Bielik. All rights reserved.
//

import Foundation

protocol InputValidating {
    var componentValidator: ComponentValidator? { get }
}

extension InputValidating {
    func validate(component: ValidatableComponent) {
        DispatchQueue.global(qos: .background).async {
            componentValidator?.validate(component: component)
        }
    }
}
