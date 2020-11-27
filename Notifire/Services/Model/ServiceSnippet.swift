//
//  ServiceSnippet.swift
//  Notifire
//
//  Created by David Bielik on 22/09/2020.
//  Copyright © 2020 David Bielik. All rights reserved.
//

import Foundation

struct ServiceSnippet: Codable, ServiceRepresentable {
    var name: String
    var id: Int
    var image: String
}
