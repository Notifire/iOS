//
//  Stylable.swift
//  Notifire
//
//  Created by David Bielik on 13/10/2018.
//  Copyright © 2018 David Bielik. All rights reserved.
//

import UIKit

protocol Stylable {
    associatedtype Style

    func set(style: Style)
}
