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

    struct Image: Codable, Equatable {
        let small: String
        let medium: String
        let large: String
    }

    let name: String
    let image: Image?
    let id: Int
    let levels: Levels
    let apiKey: String
    let updatedAt: Date

    var asServiceSnippet: ServiceSnippet {
        return ServiceSnippet(name: name, id: id, image: image)
    }
}
