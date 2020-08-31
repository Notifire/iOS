//
//  ValidatableComponent.swift
//  Notifire
//
//  Created by David Bielik on 06/09/2018.
//  Copyright © 2018 David Bielik. All rights reserved.
//

import UIKit

protocol ValidatableComponent: class {
    var validatableInput: String { get }
    var rules: [ComponentRule] { get set }
    var validityState: ValidatableComponentState { get set }
    var showsValidState: Bool { get set }
}

extension ValidatableComponent {
    var isValid: Bool {
        guard case .valid = validityState else {
            return false
        }
        return true
    }
}

extension ValidatableComponent where Self: UITextField {
    var validatableInput: String {
        return text ?? ""
    }
}
