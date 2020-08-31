//
//  InputValidatingViewModel.swift
//  Notifire
//
//  Created by David Bielik on 06/09/2018.
//  Copyright © 2018 David Bielik. All rights reserved.
//

import Foundation

class InputValidatingViewModel: InputValidating {
    
    // MARK: - Properties
    // MARK: InputValidating
    var isValid: Bool = false {
        didSet {
            guard isValid != oldValue else { return }
            afterValidation?(isValid)
        }
    }
    var componentValidator: ComponentValidator?
    let notifireApiManager: NotifireAPIManager
    
    // MARK: Callbacks
    var afterValidation: ((Bool) -> Void)?
    
    // MARK: - Initialization
    init(notifireApiManager: NotifireAPIManager = NotifireAPIManagerFactory.createAPIManager()) {
        self.notifireApiManager = notifireApiManager
    }
    
    // MARK: - Methods
    func createComponentValidator(with components: [ValidatableComponent]) {
        if let activeComponentValidator = self.componentValidator {
            activeComponentValidator.afterValidationCallback = nil
            self.componentValidator = nil
        }
        let componentValidator = ComponentValidator(components: components, apiManager: notifireApiManager)
        componentValidator.afterValidationCallback = { [weak self] valid in
            self?.afterValidation?(valid)
        }
        self.componentValidator = componentValidator
    }
}
