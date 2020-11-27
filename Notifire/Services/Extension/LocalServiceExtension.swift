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
        id = service.id
        updateDataExceptID(from: service)
    }

    func updateDataExceptID(from service: Service) {
        name = service.name
        serviceAPIKey = service.apiKey
        updatedAt = service.updatedAt
        info = service.levels.info
        warning = service.levels.warning
        error = service.levels.error
    }

    func updateData(from serviceSnippet: ServiceSnippet) {
        id = serviceSnippet.id
        updateDataExceptID(from: serviceSnippet)
    }

    func updateDataExceptID(from serviceSnippet: ServiceSnippet) {
        name = serviceSnippet.name
        smallImageURLString = serviceSnippet.image
    }

    var asServiceUpdateRequestBody: ServiceUpdateRequestBody {
        return ServiceUpdateRequestBody(name: name, id: id, levels: Service.Levels(info: info, warning: warning, error: error), image: smallImageDataString)
    }

    var asServiceSyncData: SyncServicesRequestBody.ServiceSyncData {
        return SyncServicesRequestBody.ServiceSyncData(id: id, updatedAt: updatedAt)
    }
}
