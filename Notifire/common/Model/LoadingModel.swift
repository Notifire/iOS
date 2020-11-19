//
//  LoadingModel.swift
//  Notifire
//
//  Created by David Bielik on 17/11/2020.
//  Copyright © 2020 David Bielik. All rights reserved.
//

import Foundation

/// A model class that should be used with models that require loading
class LoadingModel {

    // MARK: - Properties
    public var isLoading: Bool = false {
           didSet {
               guard oldValue != isLoading else { return }
               onLoadingChange?(isLoading)
           }
       }

    /// Called whenever `isLoading` is toggled.
    public var onLoadingChange: ((Bool) -> Void)?

    /// Toggle the `isLoading` value.
    public func toggle() {
        isLoading = !isLoading
    }
}

class StateModel<State: Equatable> {

    public var state: State {
        didSet {
            guard oldValue != state else { return }
            onStateChange?(oldValue, state)
        }
    }

    public var onStateChange: ((State, State) -> Void)?

    init(defaultValue: State) {
        self.state = defaultValue
    }
}
