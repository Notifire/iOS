//
//  Config.swift
//  Notifire
//
//  Created by David Bielik on 23/02/2018.
//  Copyright © 2018 David Bielik. All rights reserved.
//

import Foundation

class Config {
    static let shared = Config()
    
    private struct Key {
        static let URL = "API_URL"
    }
    private let fileName = "Info"
    private let type = "plist"
    
    // MARK: Private
    private init() {
        setup()
    }
    
    private func setup() {
        let plistPath = Bundle.main.path(forResource: fileName, ofType: type)!
        let plistDict = NSDictionary(contentsOfFile: plistPath)!
        
        apiUrlString = (plistDict[Config.Key.URL] as? String) ?? ""
    }
    
    // MARK: Public
    public var apiUrlString: String = ""
}
