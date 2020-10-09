//
//  PaginationHandler.swift
//  Notifire
//
//  Created by David Bielik on 30/09/2020.
//  Copyright © 2020 David Bielik. All rights reserved.
//

import Foundation

class PaginationHandler {

    enum PaginationState: Equatable {
        case initial
        case partiallyPaginated(lastServiceID: String)
        case paginated
    }

    // MARK: - Properties

    /// The last id of a ServiceSnippet that was fetched from the remote API (on the last 'page').
    /// Used to synchronize paginated services after coming back from offline mode.
    var paginationState: PaginationState = .initial
    /// The maximum number of services displayed on one 'page'
    let servicesPaginationLimit = 25

    var noPagesFetched: Bool {
        return paginationState == .initial
    }

    var shouldPaginate: Bool {
        return paginationState != .paginated
    }

    var isFullyPaginated: Bool {
        return paginationState == .paginated
    }

    // MARK: - Methods
    /// Updates the pagination state depending on the latest array of `ServiceRepresentable` that was received from a remote call.
    func updatePaginationState(_ latestRepresentables: [ServiceRepresentable]) {
        guard servicesPaginationLimit > 0 else { return }

        if latestRepresentables.isEmpty || latestRepresentables.count < servicesPaginationLimit {
            // we've already reached the end of user's services
            // don't change the `lastPageRemoteServiceID`
            paginationState = .paginated
        } else if latestRepresentables.count == servicesPaginationLimit, let lastService = latestRepresentables.last {
            paginationState = .partiallyPaginated(lastServiceID: lastService.id)
        }
    }

    /// Creates `PaginationData` depending on the current pagination state.
    func createPaginationData() -> PaginationData? {
        switch paginationState {
        case .initial, .paginated:
            // fetch first page
            return nil
        case .partiallyPaginated(let id):
            // 'after=id'
            return PaginationData(mode: .after, id: id)
        }
    }
}
