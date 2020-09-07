//
//  TabBarGestureHandler.swift
//  Notifire
//
//  Created by David Bielik on 07/09/2020.
//  Copyright © 2020 David Bielik. All rights reserved.
//

import UIKit

/// This class encapsulates the logic for TabBar gestures and their interaction.
class TabBarGestureHandler: NSObject {

    // MARK: - Properties
    let numberOfTabs: CGFloat
    var tabPressActionData: TabPressActionData?

    // MARK: Weak
    /// The view in which the gesture recognizer computes the location of touches.
    weak var gestureRecognizerSuperview: UIView!

    // MARK: Private
    private var bounds: CGRect { return gestureRecognizerSuperview.bounds }

    // MARK: Actions
    /// Called when a gesture on a Tab is detected as valid.
    /// - parameter tabIndex: the index of a tab that detected a valid gesture
    var onTabGestureStarting: ((_ tabIndex: Int) -> Void)?

    /// Called when the detected gesture on a tab should start ending.
    /// - parameter tabIndex: the index of a tab that detected a valid gesture
    /// - parameter useSpring: `true` if a spring animation should be used, `false` otherwise
    var onTabGestureEnding: ((_ tabIndex: Int, _ useSpring: Bool) -> Void)?

    var onTabGestureCompleted: ((_ tabIndex: Int) -> Void)?

    // MARK: - Initialization
    init(numberOfTabs: Int, view: UIView) {
        self.numberOfTabs = CGFloat(numberOfTabs)
        self.gestureRecognizerSuperview = view
    }

    // MARK: - Private
    /// `true` every 10 pixels
    private func shouldPanGestureSlowDown(in location: CGPoint) -> Bool {
        return Int(location.x + location.y) % 10 == 0
    }

    // MARK: - Specific Gesture Handlers
    // MARK: PressType.short
    private func handleShortBegan(currentIndex: Int) {
        if let tabAction = tabPressActionData, !tabAction.secondTouchDetected {
            // If a previous action exists => this was triggered by .began on a new Tab if we haven't detected a second touch yet
            // Gesture ending callback for the previous (lastIndex) tab
            onTabGestureEnding?(tabAction.lastIndex, true)
            // update the lastIndex to the current one
            tabPressActionData?.lastIndex = currentIndex
            // Gesture starting callback for the current tab
            onTabGestureStarting?(currentIndex)
            // second touch detected flag
            tabPressActionData?.secondTouchDetected = true
        } else {
            // If no previous action exists => start a new tab action
            // instantiate the TabPressActionData variable
            tabPressActionData = TabPressActionData(current: currentIndex)
            onTabGestureStarting?(currentIndex)
        }
    }

    private func handleShortChanged(currentIndex: Int, touchLocation: CGPoint) {
        // Guard that some tab action is already in progress
        guard let tabAction = tabPressActionData else { return }
        // If we have two fingers, slow down the animation triggers
        if tabAction.secondTouchDetected {
            guard shouldPanGestureSlowDown(in: touchLocation) else { return }
        }
        // Guard that a long press isn't already in progress
        guard !tabAction.longPressActivated else { return }
        if tabAction.lastIndex != currentIndex {
            // Finger is moving across tabs, lastIndex was different than the currentIndex
            onTabGestureEnding?(tabAction.lastIndex, false)
            // update the lastIndex to the current one
            tabPressActionData?.lastIndex = currentIndex
            onTabGestureStarting?(currentIndex)
        }
    }

    private func handleShortEnded(currentIndex: Int) {
        if let tabAction = tabPressActionData {
            // if a tabAction is already in progress
            onTabGestureEnding?(currentIndex, true)
            guard !tabAction.longPressActivated else { return }
            // Finish the tab action
            tabPressActionData = nil
            guard !tabAction.didExitInitialTabArea else { return }
            // Trigger the completed action
            onTabGestureCompleted?(currentIndex)
        } else {
            onTabGestureEnding?(currentIndex, true)
        }
    }

    // MARK: PressType.long
    private func handleLongBegan(currentIndex: Int) {
        // Guard that some tab action is already in progress
        guard let tabAction = tabPressActionData else { return }
        tabPressActionData?.lastIndex = currentIndex
        tabPressActionData?.longPressActivated = true
        onTabGestureEnding?(currentIndex, true)
        guard !tabAction.didExitInitialTabArea else {
            onTabGestureEnding?(tabAction.lastIndex, true)
            return
        }
        // Trigger the action
        onTabGestureCompleted?(currentIndex)
        // Finish the tab action
        tabPressActionData = nil
    }

    private func handleLongChanged(currentIndex: Int, touchLocation: CGPoint) {
        // Guard that some tab action is already in progress
        guard let tabAction = tabPressActionData else { return }
        // If we have two fingers, slow down the animation triggers
        if tabAction.secondTouchDetected {
            guard shouldPanGestureSlowDown(in: touchLocation) else { return }
        }
        if tabAction.lastIndex != currentIndex {
            // Finger is moving across tabs, lastIndex was different than the currentIndex
            // Start backward for lastIndex
            onTabGestureEnding?(tabAction.lastIndex, false)
            // update the lastIndex to the current one
            tabPressActionData?.lastIndex = currentIndex
            // Start forward for currentIndex
            onTabGestureStarting?(currentIndex)
        }
    }

    private func handleLongEnded(currentIndex: Int) {
        onTabGestureEnding?(currentIndex, true)
        if let tabAction = tabPressActionData {
            // if a tabAction is already in progress
            if tabAction.lastIndex != currentIndex {
                onTabGestureStarting?(tabAction.lastIndex)
            }
            // Finish the tab action
            tabPressActionData = nil
            guard !tabAction.didExitInitialTabArea else { return }
            // Trigger the completed action
            onTabGestureCompleted?(currentIndex)
        }
    }

    // MARK: - Public
    /// The main gesture recognizer target function. All of the TabBar recognizers use this function.
    @objc public func pressGestureHandler(_ gestureRecognizer: TabBarPressGestureRecognizer) {
        let touchLocation = gestureRecognizer.location(in: gestureRecognizerSuperview)
        let oneTabWidth = bounds.width / numberOfTabs
        let currentTabIndex = Int(touchLocation.x / oneTabWidth)

        // Check if the touch is still inside the bounds
        guard bounds.contains(touchLocation) else {
            // If not, check if there is an ongoing press action
            guard let tabAction = tabPressActionData else { return }
            // If there is, cancel it
            if tabAction.lastIndex != currentTabIndex {
                // end the previous tab
                onTabGestureEnding?(tabAction.lastIndex, true)
            }
            // End the current tab
            onTabGestureEnding?(currentTabIndex, true)
            tabPressActionData = nil
            return
        }

        switch (gestureRecognizer.pressType, gestureRecognizer.state) {
        case (.short, .began):
            handleShortBegan(currentIndex: currentTabIndex)
        case (.short, .changed):
            handleShortChanged(currentIndex: currentTabIndex, touchLocation: touchLocation)
        case (.short, .ended):
            handleShortEnded(currentIndex: currentTabIndex)
        case (.long, .began):
            handleLongBegan(currentIndex: currentTabIndex)
        case (.long, .changed):
            handleLongChanged(currentIndex: currentTabIndex, touchLocation: touchLocation)
        case (.long, .ended):
            handleLongEnded(currentIndex: currentTabIndex)
        default:
            guard let tabAction = tabPressActionData else { return }
            // Graceful shutdown
            if tabAction.lastIndex != currentTabIndex {
                onTabGestureEnding?(tabAction.lastIndex, true)
            }
            onTabGestureEnding?(currentTabIndex, true)
            tabPressActionData = nil
        }
    }

}
