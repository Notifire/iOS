//
//  UIViewKeyframeAnimationOptions+Init.swift
//  Notifire
//
//  Created by David Bielik on 19/11/2020.
//  Copyright © 2020 David Bielik. All rights reserved.
//

import UIKit

extension UIView.KeyframeAnimationOptions {

    /// Initialize `UIView.KeyframeAnimationOptions` from `UIView.AnimationOptions`
    init(animationOptions: UIView.AnimationOptions) {
        self.init(rawValue: animationOptions.rawValue)
    }

}
