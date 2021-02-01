//
//  ServiceSnippet.swift
//  Notifire
//
//  Created by David Bielik on 22/09/2020.
//  Copyright © 2020 David Bielik. All rights reserved.
//

import Foundation

struct ServiceSnippet: Codable {
    var name: String
    var id: Int
    var image: Service.Image?
}

extension ServiceSnippet: ServiceRepresentable {
    var imageURL: URL? {
        guard let img = image else { return nil }
        return URL(string: img.small)
    }
}
