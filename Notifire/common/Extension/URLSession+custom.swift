//
//  URLSession+custom.swift
//  Notifire
//
//  Created by David Bielik on 22/12/2020.
//  Copyright © 2020 David Bielik. All rights reserved.
//

import Foundation

// MARK: - URLSession
extension URLSession {
    /// A singleton for URLSession with `URLSessionConfiguration.custom`
    static let custom: URLSession = {
        return URLSession(configuration: URLSessionConfiguration.custom)
    }()
}

// MARK: - URLSessionConfiguration
extension URLSessionConfiguration {

    /// A custom `URLSessionConfiguration` that waits for connectivity.
    static let custom: URLSessionConfiguration = {
        let configuration = URLSessionConfiguration.default
        // 5 Minutes
        configuration.timeoutIntervalForRequest = 300
        configuration.waitsForConnectivity = true
        return configuration
    }()
}
