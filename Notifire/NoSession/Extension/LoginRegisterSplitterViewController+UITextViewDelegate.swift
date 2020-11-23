//
//  LoginRegisterSplitterViewController+UITextViewDelegate.swift
//  Notifire
//
//  Created by David Bielik on 23/11/2020.
//  Copyright © 2020 David Bielik. All rights reserved.
//

import UIKit

extension LoginRegisterSplitterViewController: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        // Make sure the use has tapped the hypertext (interaction == 0)
        guard
            interaction.rawValue == 0,
            URL == Config.privacyPolicyURL
        else { return true }
        delegate?.shouldPresentPrivacyPolicy()
        return false
    }
}
