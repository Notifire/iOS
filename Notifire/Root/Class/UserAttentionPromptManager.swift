//
//  UserAttentionPromptManager.swift
//  Notifire
//
//  Created by David Bielik on 21/11/2020.
//  Copyright © 2020 David Bielik. All rights reserved.
//

import Foundation

/// Manage all `UserAttentionPrompt` objects in a queue (present and finish them when needed).
/// This class acts as a serial queue for all prompts, so the user doesn't get two (not user-initiated) alerts / popouts at the same time.
class UserAttentionPromptManager {

    // MARK: - Properties
    /// FIFO Queue for UserAttentionPrompts
    /// FIXME: Maybe this needs a weak wrapper for the user attention prompts?
    var userAttentionPromptsQueue = [UserAttentionPrompt]() {
        didSet {
            print(userAttentionPromptsQueue.count)
            updateTimer()
        }
    }

    private var timer: RepeatingTimer?

    // MARK: - Methods
    /// Add a new `UserAttentionPrompt` to the top of the queue.
    func add(userAttentionPrompt: UserAttentionPrompt) {
        userAttentionPromptsQueue.append(userAttentionPrompt)
    }

    /// Start or stop the timer depending on the queue emptiness.
    func updateTimer() {
        if userAttentionPromptsQueue.isEmpty {
            // Queue is empty, we don't need the timer anymore
            timer?.suspend()
            timer = nil
        } else {
            // Queue is not empty, initialize it
            guard timer == nil else { return }
            let newTimer = RepeatingTimer(timeInterval: 5, queue: nil)
            newTimer.eventHandler = { [weak self] in
                DispatchQueue.main.async {
                    self?.checkAndUpdatePromptQueue()
                }
            }
            newTimer.resume()
            self.timer = newTimer
        }
    }

    /// Update the first element in the queue depending on its state.
    func checkAndUpdatePromptQueue() {
        guard !userAttentionPromptsQueue.isEmpty, let first = userAttentionPromptsQueue.first else { return }

        if first.stateModel.state == .waitingToPresent {
            Logger.log(.debug, "\(self) presenting user attention prompt (\(first.name)).")
            // The first Prompt is waiting to be presented
            // 1. present it
            first.present()
            // 2. Set onStateChange
            first.stateModel.onStateChange = { [weak self] _, new in
                guard let `self` = self, new == .finished else { return }
                // Remove the prompt from the queue when it finishes
                self.userAttentionPromptsQueue.removeFirst()
                Logger.log(.debug, "\(self) finished presenting user attention prompt (\(first.name)).")
            }
        } else {
            // The first Prompt is currently presenting or finished
            // Don't do anything
        }
    }
}
