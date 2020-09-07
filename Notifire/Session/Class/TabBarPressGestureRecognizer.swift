//
//  TabBarPressGestureRecognizer.swift
//  Notifire
//
//  Created by David Bielik on 07/09/2020.
//  Copyright © 2020 David Bielik. All rights reserved.
//

import UIKit

/// Handles the gestures on the TabBar
class TabBarPressGestureRecognizer: UILongPressGestureRecognizer {

    // MARK: - PressType
    /// Determines the type of a press required to trigger the UIControl.Event
    enum PressType {
        /// Detects *short* presses. A short press is a Tap but also tracks dragging.
        case short
        /// Detects *long* presses.
        case long

        /// The minimum press duration that triggers `UIGestureRecognizer.State.began`
        var minimumPressDuration: TimeInterval {
            switch self {
            case .short: return 0
            case .long: return 0.5
            }
        }

        /// Minimum movement in pixels before the gesture fails. Once the state is `UIGestureRecognizer.State.began` and higher, this property has no effect.
        var allowableMovement: CGFloat {
            switch self {
            case .short: return 25
            case .long: return 40
            }
        }
    }

    // MARK: - Properties
    let pressType: PressType
    weak var button: UIButton?

    // MARK: - Initialization
    init(target: (Any & UIGestureRecognizerDelegate)?, action: Selector?, pressType: PressType, button: UIButton) {
        self.pressType = pressType
        self.button = button
        super.init(target: target, action: action)
        delegate = target

        // UILongPressGestureRecognizer settings
        minimumPressDuration = pressType.minimumPressDuration
        allowableMovement = pressType.allowableMovement
        cancelsTouchesInView = false
    }
}
