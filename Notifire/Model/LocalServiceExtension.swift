//
//  LocalServiceExtension.swift
//  Notifire
//
//  Created by David Bielik on 17/11/2018.
//  Copyright © 2018 David Bielik. All rights reserved.
//

import Foundation

extension LocalService {
    func updateData(from service: Service) {
        uuid = service.uuid
        updateDataExceptUUID(from: service)
    }

    func updateDataExceptUUID(from service: Service) {
        name = service.name
        serviceKey = service.apiKey
        updatedAt = service.updatedAt
        info = service.levels.info
        warning = service.levels.warning
        error = service.levels.error
    }

    var asService: Service {
        //et validUpdatedAt = updatedAt ?? Date(timeIntervalSince1970: 0)
        return Service(name: name, uuid: uuid, levels: Service.Levels(info: info, warning: warning, error: error), apiKey: serviceKey, updatedAt: nil)
    }

    var asServiceRequestBody: ServiceRequestBody {
        return ServiceRequestBody(name: name, uuid: uuid, levels: Service.Levels(info: info, warning: warning, error: error))
    }
}
