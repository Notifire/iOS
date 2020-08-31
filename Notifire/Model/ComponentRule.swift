//
//  ComponentRule.swift
//  Notifire
//
//  Created by David Bielik on 06/09/2018.
//  Copyright © 2018 David Bielik. All rights reserved.
//

import Foundation

enum RuleValidityOption {
    case cantTell(error: Error?)
    case obeyed
    case broken
}

struct ComponentRule {
    enum Kind {
        case minimum(length: Int)
        case maximum(length: Int)
        case regex(NSRegularExpression)
        case equalToComponent(ValidatableComponent)
        case equalToString(String)
        case validity(CheckValidityOption)
    }
    
    let kind: Kind
    let showIfBroken: Bool
    
    static var passwordRules: [ComponentRule] {
        return [
            ComponentRule(kind: .minimum(length: Settings.Text.minimumPasswordLength), showIfBroken: false),
            ComponentRule(kind: .maximum(length: Settings.Text.maximumPasswordLength), showIfBroken: true)
        ]
    }
}

extension ComponentRule: CustomStringConvertible {
    var description: String {
        switch kind {
        case .minimum(let minLength): return "Minimum length is \(minLength)."
        case .maximum(let maxLength): return "Maximum length exceeded. (\(maxLength))"
        case .regex: return "Invalid characters used."
        case .validity(let option): return "This \(option.rawValue) is not available."
        case .equalToString, .equalToComponent: return ""
        }
    }
}

