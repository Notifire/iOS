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
            DispatchQueue.main.async { [weak self] in
                component.validityState = state
                self?.updateComponentsValidity()
            }
        }
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
            guard component.validatableInput == currentText else { return }
            guard let nextRule = ruleIterator.next() else {
                setComponent(state: .valid)
                return
            }
            // Enable loading indicator if needed
            if nextRule.showsLoadingIndicator {
                setComponent(state: .validating)
            }
            isRuleObeyed(rule: nextRule, in: currentText, completion: handler)
        }
        guard !currentText.isEmpty else {
            setComponent(state: .neutral)
            return
        }
        guard let firstRule = ruleIterator.next() else { return }
        // Enable loading indicator if needed
        if firstRule.showsLoadingIndicator {
            setComponent(state: .validating)
        }
        isRuleObeyed(rule: firstRule, in: currentText, completion: handler)
    }

    ///
    /// - Returns:
    ///    - `true` if the rule is obeyed, false otherwise
    func isRuleObeyed(rule: ComponentRule, in string: String, completion: @escaping ((ComponentRule, Bool) -> Void)) {
        let mainQueueCompletion: ((ComponentRule, Bool) -> Void) = { rule, valid in
            DispatchQueue.main.async {
                completion(rule, valid)
            }
        }
        switch rule.kind {
        case .minimum(let minLength):
            mainQueueCompletion(rule, string.count >= minLength)
        case .maximum(let maxLength):
            mainQueueCompletion(rule, string.count <= maxLength)
        case .regex(let regularExpression):
            let expressionTest = NSPredicate(format: "SELF MATCHES %@", regularExpression)
            mainQueueCompletion(rule, expressionTest.evaluate(with: string))
        case .equalToString(let equalString):
            mainQueueCompletion(rule, string == equalString)
        case .notEqualToString(let notEqualString):
            mainQueueCompletion(rule, string != notEqualString)
        case .equalToComponent(let component):
            mainQueueCompletion(rule, string == component.validatableInput)
        case .notEqualToComponent(let component):
            mainQueueCompletion(rule, string != component.validatableInput)
        case .validity(let option):
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.34) { [weak self] in
                self?.apiManager.checkValidity(option: option, input: string) { result in
                    switch result {
                    case .error:
                        mainQueueCompletion(rule, false)
                    case .success(let response):
                        mainQueueCompletion(rule, response.valid)
                    }
                }
            }

        }
    }
}
