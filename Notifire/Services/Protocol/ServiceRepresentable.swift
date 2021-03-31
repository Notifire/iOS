//
//  ServiceRepresentable.swift
//  Notifire
//
//  Created by David Bielik on 21/09/2020.
//  Copyright © 2020 David Bielik. All rights reserved.
//

import Foundation

/// Represents any object that can be displayed as a service.
protocol ServiceRepresentable {
    /// The name of the servic
    var name: String { get }
    var id: Int { get }
    var image: Service.Image? { get }
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
    var imageURL: URL? {
        guard let urlString = largeImageURLString ?? mediumImageURLString ?? smallImageURLString else { return nil }
        return URL(string: urlString)
    }

    var image: Service.Image? {
        return Service.Image(
            smallString: smallImageURLString,
            mediumString: mediumImageURLString,
            largeString: largeImageURLString
        )
    }
}
