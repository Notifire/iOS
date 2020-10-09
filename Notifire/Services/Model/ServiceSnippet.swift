//
//  ServiceSnippet.swift
//  Notifire
//
//  Created by David Bielik on 22/09/2020.
//  Copyright © 2020 David Bielik. All rights reserved.
//

import Foundation

struct ServiceSnippet: ServiceRepresentable, Codable {
    var name: String
    var id: String
    var imageURLString: String

    private enum CodingKeys: String, CodingKey {
        case name, id, imageURLString = "image"
    }
}
