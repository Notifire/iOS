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
        case regex(String)
        case equalToComponent(ValidatableComponent)
        case equalToString(String)
        case validity(CheckValidityOption)
    }

    let kind: Kind
    let showIfBroken: Bool
    var brokenRuleDescription: String?

    static let passwordRules: [ComponentRule] = {
        return [
            ComponentRule(kind: .minimum(length: Settings.Text.minimumPasswordLength), showIfBroken: false),
            ComponentRule(kind: .maximum(length: Settings.Text.maximumPasswordLength), showIfBroken: true)
        ]
    }()

    /// email length + checks for availability of the email address
    static let createEmailRules: [ComponentRule] = {
        return emailBaseRules + [
            ComponentRule(kind: .validity(.email), showIfBroken: true)
        ]
    }()

    /// email length + email regex
    static let emailRules: [ComponentRule] = {
        return emailBaseRules + [
            ComponentRule.init(kind: .regex("[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"), showIfBroken: true, brokenRuleDescription: "You haven't entered a valid e-mail address.")
        ]
    }()

    /// Email length rules
    private static let emailBaseRules: [ComponentRule] = {
        return [
            ComponentRule(kind: .minimum(length: 1), showIfBroken: false),
            ComponentRule(kind: .maximum(length: Settings.Text.maximumUsernameLength), showIfBroken: true)
        ]
    }()
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
