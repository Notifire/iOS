//
//  ServiceIdentifiable.swift
//  Notifire
//
//  Created by David Bielik on 25/12/2020.
//  Copyright © 2020 David Bielik. All rights reserved.
//

import Foundation

/// Represents any potential service.
protocol ServiceIdentifiable {
    var id: Int { get }
}

extension LocalService: ServiceIdentifiable {}
extension ServiceSnippet: ServiceIdentifiable {}
extension Service: ServiceIdentifiable {}
