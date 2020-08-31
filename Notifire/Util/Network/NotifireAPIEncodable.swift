//
//  NotifireAPIEncodable.swift
//  Notifire
//
//  Created by David Bielik on 08/09/2018.
//  Copyright © 2018 David Bielik. All rights reserved.
//

import Foundation

typealias NotifireAPIEncodable = Encodable      // represents encodable RequestBody
typealias NotifireAPICodable = NotifireAPIDecodable & NotifireAPIEncodable

struct EmptyRequestBody: NotifireAPIEncodable, NotifireAPIDecodable {}

struct RegisterRequestBody: NotifireAPIEncodable {
    let username: String
    let email: String
    let password: String
}

struct ResendConfirmRequestBody: NotifireAPIEncodable {
    let email: String
}

struct ConfirmAccountRequestBody: NotifireAPIEncodable {
    let token: String
}

struct RegisterDeviceRequestBody: NotifireAPIEncodable {
    let deviceToken: String
    let enabled: Bool
}

struct GenerateAccessTokenRequestBody: NotifireAPIEncodable {
    let refreshToken: String
}

struct LoginRequestBody: NotifireAPIEncodable {
    let username: String
    let password: String
}

struct ServiceCreationBody: NotifireAPIEncodable {
    let name: String
    let image: String
    let levels = Service.Levels(info: true, warning: true, error: true)
}

struct PasswordValidationRequestBody: NotifireAPIEncodable {
    let password: String
}

struct ServiceRequestBody: NotifireAPIEncodable {
    let name: String
    let uuid: String
    let levels: Service.Levels
}


struct ChangeServiceKeyBody: NotifireAPIEncodable {
    let service: Service
    let password: String
}
