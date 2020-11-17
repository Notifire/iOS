//
//  ComponentValidator.swift
//  Notifire
//
//  Created by David Bielik on 06/09/2018.
//  Copyright © 2018 David Bielik. All rights reserved.
//

import Foundation

class ComponentValidator {

    // MARK: - Properties
    var allComponentsValid: Bool = false {
        didSet {
            // notify only if the previous value has changed
            guard allComponentsValid != oldValue else { return }
            afterValidationCallback?(allComponentsValid)
        }
    }
    var components: [ValidatableComponent]
    var afterValidationCallback: ((Bool) -> Void)?
    let apiManager: NotifireAPIManager

    // MARK: - Initialization
    init(components: [ValidatableComponent], apiManager: NotifireAPIManager) {
        self.components = components
        self.apiManager = apiManager
    }

    deinit {
        components = []
    }

    // MARK: - Validation
    func updateComponentsValidity() {
        let validComponents = components.filter { $0.isValid }.count
        allComponentsValid = validComponents == components.count
    }

    func validate(component: ValidatableComponent) {
        let currentText = component.validatableInput
        func setComponent(state: ValidatableComponentState) {
            guard component.validatableInput == currentText else { return }
            component.validityState = state
            self.updateComponentsValidity()
        }
        setComponent(state: .validating)
        guard !component.rules.isEmpty else {
            setComponent(state: .valid)
            return
        }
        var ruleIterator = component.rules.makeIterator()
        func handler(rule: ComponentRule, valid: Bool) {
            guard valid else {
                setComponent(state: .invalid(rule: rule))
                return
            }
            guard let nextRule = ruleIterator.next() else {
                setComponent(state: .valid)
                return
            }
            isRuleObeyed(rule: nextRule, in: currentText, completion: handler)
        }
        guard !currentText.isEmpty else {
            setComponent(state: .neutral)
            return
        }
        guard let firstRule = ruleIterator.next() else { return }
        isRuleObeyed(rule: firstRule, in: currentText, completion: handler)
    }

    ///
    /// returns:
    ///    - `true` if the rule is obeyed, false otherwise
    func isRuleObeyed(rule: ComponentRule, in string: String, completion: @escaping ((ComponentRule, Bool) -> Void)) {
        switch rule.kind {
        case .minimum(let minLength):
            completion(rule, string.count >= minLength)
        case .maximum(let maxLength):
            completion(rule, string.count <= maxLength)
        case .regex(let regularExpression):
            let expressionTest = NSPredicate(format: "SELF MATCHES %@", regularExpression)
            completion(rule, expressionTest.evaluate(with: string))
        case .equalToString(let equalString):
            completion(rule, string == equalString)
        case .equalToComponent(let component):
            completion(rule, string == component.validatableInput)
        case .notEqualToComponent(let component):
            completion(rule, string != component.validatableInput)
        case .validity(let option):
            apiManager.checkValidity(option: option, input: string) { result in
                switch result {
                case .error:
                    completion(rule, false)
                case .success(let response):
                    completion(rule, response.valid)
                }
            }
        }
    }
}
