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
    var snippetImageURLString: String?

    private enum CodingKeys: String, CodingKey {
        case name, id, snippetImageURLString = "image"
    }
}

extension ServiceSnippet: ServiceRepresentable {
    var imageURLString: String? {
        return snippetImageURLString
    }
}
