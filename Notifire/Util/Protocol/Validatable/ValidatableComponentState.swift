//
//  ValidatableComponentState.swift
//  Notifire
//
//  Created by David Bielik on 06/09/2018.
//  Copyright © 2018 David Bielik. All rights reserved.
//

import Foundation


enum ValidatableComponentState {
    case neutral
    case validating
    case invalid(rule: ComponentRule)
    case valid
}
