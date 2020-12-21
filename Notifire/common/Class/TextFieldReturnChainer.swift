//
//  TextFieldReturnChainer.swift
//  Notifire
//
//  Created by David Bielik on 16/11/2020.
//  Copyright © 2020 David Bielik. All rights reserved.
//

import UIKit

/// Chains return keys on the user's keyboard to switch into the next textfield until the last one is reached.
/// `onFinalReturn` is called whenever the return key is pressed on the last textfield.
class TextFieldReturnChainer {

    // MARK: - Properties
    /// Called when the final return is pressed.
    var onFinalReturn: (() -> Void)?

    private var textFields: [UITextField]

    /// - Parameters:
    ///     -   textFields: the text fields that will be chained for return action
    ///     -   setLastReturnKeyTypeToDone: whether to set the last textfield's `returnKeyType` to `.done`
    /// - Note: Specify the textFields in order in which they should be chained.
    init(textFields: [UITextField], setLastReturnKeyTypeToDone: Bool = true, onFinalReturn: (() -> Void)? = nil) {
        self.textFields = textFields
        self.onFinalReturn = onFinalReturn

        if setLastReturnKeyTypeToDone, let last = textFields.last {
            last.returnKeyType = .done
        }

        // Add targets for each textField
        textFields.forEach {
            $0.addTarget(self, action: #selector(didStopEditing(textField:)), for: .editingDidEndOnExit)
        }
    }

    convenience init(textField: UITextField, setLastReturnKeyTypeToDone: Bool = true, onFinalReturn: (() -> Void)? = nil) {
        self.init(textFields: [textField], setLastReturnKeyTypeToDone: setLastReturnKeyTypeToDone, onFinalReturn: onFinalReturn)
    }

    // MARK: - Private
    /// Handle 'return' press
    @objc private func didStopEditing(textField: UITextField) {
        guard !textFields.isEmpty else {
            Logger.log(.info, "\(self) textFields is empty.")
            return
        }
        guard let index = textFields.firstIndex(of: textField) else {
            Logger.log(.error, "\(self) can't find index for \(textField) in \(textFields)")
            return
        }
        let isLast = index == textFields.count - 1

        if isLast {
            onFinalReturn?()
        } else {
            textFields[index + 1].becomeFirstResponder()
        }
    }
}
