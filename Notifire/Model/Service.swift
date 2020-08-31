//
//  Service.swift
//  Notifire
//
//  Created by David Bielik on 19/10/2018.
//  Copyright © 2018 David Bielik. All rights reserved.
//

import Foundation

struct Service: NotifireAPIDecodable, NotifireAPIEncodable, Equatable {
    struct Levels: NotifireAPICodable, Equatable {
        let info: Bool
        let warning: Bool
        let error: Bool
    }
    
    let name: String
    let uuid: String
    let levels: Levels
    let apiKey: String
    let updatedAt: Date?
}

