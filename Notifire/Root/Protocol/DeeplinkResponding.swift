//
//  DeeplinkResponding.swift
//  Notifire
//
//  Created by David Bielik on 19/11/2020.
//  Copyright © 2020 David Bielik. All rights reserved.
//

import Foundation

/// ViewModel that responds to a Deeplink action.
protocol DeeplinkResponding: ViewModelRepresenting {
    var token: String { get }
    var apiManager: NotifireAPIManager { get }

    init(apiManager: NotifireAPIManager, token: String)
}
