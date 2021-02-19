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
        if let imageData = service.image {
            smallImageURLString = imageData.small.absoluteString
            mediumImageURLString = imageData.medium.absoluteString
            largeImageURLString = imageData.large.absoluteString
        } else {
            smallImageURLString = nil
            mediumImageURLString = nil
            largeImageURLString = nil
        }
    }

    func updateData(from serviceSnippet: ServiceSnippet) {
        id = serviceSnippet.id
        updateDataExceptID(from: serviceSnippet)
    }

    func updateDataExceptID(from serviceSnippet: ServiceSnippet) {
        name = serviceSnippet.name
        if let imageData = serviceSnippet.image {
            smallImageURLString = imageData.small.absoluteString
            mediumImageURLString = imageData.medium.absoluteString
            largeImageURLString = imageData.large.absoluteString
        }
    }

    func toServiceUpdateRequestBody(deleteImage: Bool = false) -> ServiceUpdateRequestBody {
        return ServiceUpdateRequestBody(name: name, id: id, levels: Service.Levels(info: info, warning: warning, error: error), deleteImage: deleteImage)
    }

    var asService: Service {
        return Service(name: name, image: image, id: id, levels: Service.Levels(info: info, warning: warning, error: error), apiKey: serviceAPIKey, updatedAt: updatedAt)
    }

    var levels: Service.Levels {
        return Service.Levels(info: info, warning: warning, error: error)
    }
}
