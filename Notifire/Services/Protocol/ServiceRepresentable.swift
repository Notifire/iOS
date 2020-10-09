//
//  ServiceRepresentable.swift
//  Notifire
//
//  Created by David Bielik on 21/09/2020.
//  Copyright © 2020 David Bielik. All rights reserved.
//

import Foundation

protocol ServiceRepresentable {
    var name: String { get }
    var id: String { get }
    var imageURLString: String { get }
}

// MARK: Equatable
/// Custom `Equatable` protocol to avoid using Generics instead of protocols in `[ServiceRepresentable]`
extension ServiceRepresentable {
    func isEqualTo(other representable: ServiceRepresentable) -> Bool {
        return id == representable.id
    }
}

// MARK: - LocalService + ServiceRepresentable
extension LocalService: ServiceRepresentable {
    var id: String {
        return uuid
    }

    var imageURLString: String {
        return rawImage
    }
}
