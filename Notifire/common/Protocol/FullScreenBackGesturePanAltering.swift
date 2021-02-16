//
//  FullScreenBackGesturePanAltering.swift
//  Notifire
//
//  Created by David Bielik on 15/02/2021.
//  Copyright © 2021 David Bielik. All rights reserved.
//

import UIKit

/// Describes objects that can alter the full screen back pan gesture.
protocol FullScreenBackGesturePanAltering {
    /// Gesture recognizers that take priority over the back pan.
    /// i.e. the back pan gesture recognizer should require failure of prioritized gesture recognizers.
    var prioritizedGestureRecognizers: [UIGestureRecognizer] { get }
}

extension NotificationsViewController: FullScreenBackGesturePanAltering {
    var prioritizedGestureRecognizers: [UIGestureRecognizer] {
        // take only the pangesturerecognizers (to get the UITableViewCell pan gesture)
        return tableView.gestureRecognizers?.filter({ $0 is UIPanGestureRecognizer }) ?? []
    }
}
