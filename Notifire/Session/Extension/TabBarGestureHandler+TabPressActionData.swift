//
//  TabBarGestureHandler+TabPressActionData.swift
//  Notifire
//
//  Created by David Bielik on 07/09/2020.
//  Copyright © 2020 David Bielik. All rights reserved.
//

import Foundation

extension TabBarGestureHandler {

    struct TabPressActionData {

        // MARK: - Properties
        /// The index of the tab that was hit by the first touch
        let initialIndex: Int
        /// The index of the tab that was hit by the last (pan/tap/longpress) gesture.
        var lastIndex: Int {
            didSet {
                // if lastIndex changes, check if it differs from the initialIndex
                // and update didExitInitialTabArea accordingly
                guard !didExitInitialTabArea, initialIndex != lastIndex else { return }
                didExitInitialTabArea = true
            }
        }
        /// Indicates if the gesture exited the initial touch tab. Determines if the tab switch should occur.
        private (set) var didExitInitialTabArea = false
        /// Indicates if the gesture was a long press
        var longPressActivated = false
        /// Indicates if a second gesture has been detected in the tabbarview (second finger)
        var secondTouchDetected = false

        // MARK: - Initialization
        init(current: Int) {
            initialIndex = current
            lastIndex = current
        }
    }
}
