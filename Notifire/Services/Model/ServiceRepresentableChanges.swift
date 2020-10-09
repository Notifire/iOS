//
//  ServiceRepresentableChanges.swift
//  Notifire
//
//  Created by David Bielik on 30/09/2020.
//  Copyright © 2020 David Bielik. All rights reserved.
//

import Foundation

/// Represents the UI changes that should occur on the displaying view
enum ServiceRepresentableChanges: CustomStringConvertible {
    /// `tableView.reloadData()` should be called when these changes occur
    case full
    /// handle the tableView changes manually per change
    case partial(changesData: ServiceRepresentableChangesData)

    var description: String {
        switch self {
        case .full: return "ServiceRepresentableChanges.full"
        case .partial(let data): return "ServiceRepresentableChanges.partial(\(data.description))"
        }
    }
}

/// The changes data used in `ServiceRepresentableChanges.partial` (e.g. whenever only a few rows should be updated / moved / removed / created)
struct ServiceRepresentableChangesData: CustomStringConvertible {
    /// The affected rows
    typealias Changes = [IndexPath]

    /// The IndexPaths of deletions that we should present
    let deletions: Changes
    /// The IndexPaths of insertions that we should present
    let insertions: Changes
    /// The IndexPaths of modifications that we should present
    let modifications: Changes
    /// /// The IndexPaths of moveRows that we should present
    let moves: [(from: IndexPath, to: IndexPath)]

    var description: String {
        return "ChangesData(deletions: \(deletions), insertions: \(insertions), modifications: \(modifications), moves: \(moves))"
    }
}
