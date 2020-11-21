//
//  UserAttentionPrompt.swift
//  Notifire
//
//  Created by David Bielik on 21/11/2020.
//  Copyright © 2020 David Bielik. All rights reserved.
//

import Foundation

/// Describes any prompt that needs user's attention. (e.g. New version update alert, Allow notifications alert)
/// These prompts shouldnt be overlapped
class UserAttentionPrompt {

    // MARK: - PromptState
    /// The state of the prompt.
    enum PromptState {
        /// When it sits in the queue
        case waitingToPresent
        /// While its presented
        case presenting
        /// When its finished presenting (waiting for the manager to remove it from queue)
        case finished
    }

    // MARK: - Properties
    let stateModel = StateModel(defaultValue: PromptState.waitingToPresent)
    let name: String

    var onPresent: (() -> Void)

    // MARK: - Initialization
    /// - Parameter name: the identifier of this user attention prompt (for logging).
    init(name: String, onPresent: @escaping (() -> Void)) {
        self.onPresent = onPresent
        self.name = name
    }

    // MARK: - Public
    /// Present the prompt.
    func present() {
        guard stateModel.state == .waitingToPresent else { return }
        stateModel.state = .presenting

        onPresent()
    }

    /// Finish the prompt presentation.
    func finish() {
        stateModel.state = .finished
    }
}
