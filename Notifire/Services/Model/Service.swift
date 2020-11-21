//
//  Service.swift
//  Notifire
//
//  Created by David Bielik on 19/10/2018.
//  Copyright © 2018 David Bielik. All rights reserved.
//

import Foundation

struct Service: Codable, Equatable {
    struct Levels: Codable, Equatable {
        let info: Bool
        let warning: Bool
        let error: Bool
    }

    let name: String
    let imageURLString: String?
    let id: Int
    let levels: Levels
    let apiKey: String
    let updatedAt: Date?

    var asServiceSnippet: ServiceSnippet {
        return ServiceSnippet(
            name: name,
            id: id,
            snippetImageURLString: imageURLString
        )
    }
}
