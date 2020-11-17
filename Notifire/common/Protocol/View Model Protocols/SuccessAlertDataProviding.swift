//
//  SuccessAlertDataProviding.swift
//  Notifire
//
//  Created by David Bielik on 17/11/2020.
//  Copyright © 2020 David Bielik. All rights reserved.
//

import Foundation

/// Describes ViewModels that provide Success Alert data.
protocol SuccessAlertDataProviding {
    var onSuccess: (() -> Void)? { get set }

    // Alert
    /// The title of the alert
    var successAlertTitle: String? { get }
    /// The text for the alert
    var successAlertText: String? { get }
    /// If the view should be dismissed after pressing OK.
    var shouldDismissViewAfterSuccessOk: Bool { get }
}

// MARK: Default Implementation
extension SuccessAlertDataProviding {
    var successAlertTitle: String? {
        return nil
    }

    var successAlertText: String? {
        return nil
    }
}
