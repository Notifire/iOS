//
//  CGPoint.swift
//  Notifire
//
//  Created by David Bielik on 25/12/2020.
//  Copyright © 2020 David Bielik. All rights reserved.
//

import UIKit

extension CGPoint {
    /// The L2 (Euclidean) distance from self to the other point.
    func distance(to otherPoint: CGPoint) -> CGFloat {
        let sum = pow(x - otherPoint.x, 2) + pow(y - otherPoint.y, 2)
        return sum.squareRoot()
    }
}
