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
    /// IF `true` then the `.neutral` state is taken as valid.
    var neutralStateValid: Bool { get }
}

extension ValidatableComponent {
    var isValid: Bool {
        switch validityState {
        case .valid: return true
        case .neutral: return neutralStateValid
        case .validating, .invalid: return false
        }
    }

    var neutralStateValid: Bool {
        return false
    }
}

extension ValidatableComponent where Self: UITextField {
    var validatableInput: String {
        return text ?? ""
    }
}
