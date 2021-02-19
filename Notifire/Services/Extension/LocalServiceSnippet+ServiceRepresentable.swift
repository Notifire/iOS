//
//  LocalServiceSnippet+ServiceRepresentable.swift
//  Notifire
//
//  Created by David Bielik on 08/02/2021.
//  Copyright © 2021 David Bielik. All rights reserved.
//

import Foundation

extension LocalServiceSnippet: ServiceRepresentable {
    var image: Service.Image? {
        return Service.Image(smallString: smallImageURLString, mediumString: mediumImageURLString, largeString: largeImageURLString)
    }
}

extension LocalServiceSnippet {
    /// The `LocalServiceSnippet` as a `ServiceSnippet`
    /// - Important: Always returns the image with `nil` even if `LocalServiceSnippet.imageURL` has a value.
    var asServiceSnippet: ServiceSnippet {
        return ServiceSnippet(name: name, id: id, image: nil)
    }
}
