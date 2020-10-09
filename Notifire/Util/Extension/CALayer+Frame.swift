//
//  CALayer+Frame.swift
//  Notifire
//
//  Created by David Bielik on 03/10/2020.
//  Copyright © 2020 David Bielik. All rights reserved.
//

import UIKit

extension CALayer {
    func setFrameWithoutAnimation(_ newFrame: CGRect) {
        CATransaction.withDisabledActions {
            frame = newFrame
        }
    }
}
