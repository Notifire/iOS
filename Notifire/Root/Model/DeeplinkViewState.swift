//
//  DeeplinkViewState.swift
//  Notifire
//
//  Created by David Bielik on 19/11/2020.
//  Copyright © 2020 David Bielik. All rights reserved.
//

import Foundation

/// The view state of the deeplinked VC.
enum DeeplinkViewState {
    case initial
    case confirming
    case failed
    case success
}
