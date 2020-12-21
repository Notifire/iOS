//
//  ComponentRule.swift
//  Notifire
//
//  Created by David Bielik on 06/09/2018.
//  Copyright © 2018 David Bielik. All rights reserved.
//

import Foundation

struct Regex {
    /// Regular expression for detecting emails
    static let email = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
}

struct ComponentRule {
    enum Kind: Equatable {
        case minimum(length: Int)
        case maximum(length: Int)
        case regex(String)
        case equalToComponent(ValidatableComponent)
        case notEqualToComponent(ValidatableComponent)
        case equalToString(String)
        case notEqualToString(String)
        case validity(CheckValidityOption)

        static func == (lhs: Kind, rhs: Kind) -> Bool {
            switch (lhs, rhs) {
            case (.minimum(let lengthLeft), .minimum(let lengthRight)): return lengthLeft == lengthRight
            case (.maximum(let lengthLeft), .maximum(let lengthRight)): return lengthLeft == lengthRight
            case (.regex(let regexL), .regex(let regexR)): return regexL == regexR
            case (.equalToComponent(let componentL), .equalToComponent(let componentR)): return componentL === componentR
            case (.notEqualToComponent(let componentL), .notEqualToComponent(let componentR)): return componentL === componentR
            case (.equalToString(let stringL), .equalToString(let stringR)): return stringL == stringR
            case (.notEqualToString(let stringL), .notEqualToString(let stringR)): return stringL == stringR
            case (.validity(let optionL), .validity(let optionR)): return optionL == optionR
            default: return false
            }
        }
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
        return emailRules + [
            ComponentRule(kind: .validity(.email), showIfBroken: true)
        ]
    }()

    /// email length + email regex
    static let emailRules: [ComponentRule] = {
        return emailBaseRules + [
            ComponentRule.init(kind: .regex(Regex.email), showIfBroken: true, brokenRuleDescription: "You haven't entered a valid e-mail address.")
        ]
    }()

    static let serviceNameRules: [ComponentRule] = {
        return [
            ComponentRule.init(kind: .minimum(length: 1), showIfBroken: false),
            ComponentRule.init(kind: .maximum(length: Settings.Text.maximumLength), showIfBroken: true, brokenRuleDescription: "The service name is too long.")
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
        case .equalToString, .notEqualToString, .equalToComponent, .notEqualToComponent: return ""
        }
    }
}
