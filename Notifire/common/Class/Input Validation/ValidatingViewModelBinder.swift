//
//  ValidatingViewModelBinder.swift
//  Notifire
//
//  Created by David Bielik on 16/11/2020.
//  Copyright © 2020 David Bielik. All rights reserved.
//

import Foundation

class ValidatingViewModelBinder {

    private let updateViewModelKeyPath: ((String, ValidatableComponent) -> Void)

    init<VM: InputValidatingViewModel>(viewModel: VM, for keyPath: ReferenceWritableKeyPath<VM, String>) {
        self.updateViewModelKeyPath = { string, component in
            viewModel[keyPath: keyPath] = string
            viewModel.validate(component: component)
        }
    }

    func updateKeyPathAndValidate(component: ValidatableComponent) {
        let string = component.validatableInput
        updateViewModelKeyPath(string, component)
    }
}
