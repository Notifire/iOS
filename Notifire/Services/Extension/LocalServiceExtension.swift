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
        if let imageData = serviceSnippet.image {
            smallImageURLString = imageData.small
            mediumImageURLString = imageData.medium
            largeImageURLString = imageData.large
        }
    }

    var asServiceUpdateRequestBody: ServiceUpdateRequestBody {
        return ServiceUpdateRequestBody(name: name, id: id, levels: Service.Levels(info: info, warning: warning, error: error), image: smallImageDataString)
    }

    var asServiceSyncData: SyncServicesRequestBody.ServiceSyncData {
        return SyncServicesRequestBody.ServiceSyncData(id: id, updatedAt: updatedAt)
    }

    var asService: Service {
        let images: Service.Image?
        if let small = smallImageURLString, let medium = mediumImageURLString, let large = largeImageURLString {
            images = Service.Image(small: small, medium: medium, large: large)
        } else {
            images = nil
        }
        return Service(name: name, image: images, id: id, levels: Service.Levels(info: info, warning: warning, error: error), apiKey: serviceAPIKey, updatedAt: updatedAt)
    }
}
