//
//  NotifireButton+Loadable.swift
//  Notifire
//
//  Created by David Bielik on 03/09/2020.
//  Copyright © 2020 David Bielik. All rights reserved.
//

import UIKit

extension NotifireButton: Loadable {
    func onLoadingStart() {
        isEnabled = false
        titleLabel?.alpha = 0
        imageView?.alpha = 0
    }

    func onLoadingFinished() {
        isEnabled = true
        titleLabel?.alpha = 1
        imageView?.alpha = 1
    }

    var spinnerStyle: UIActivityIndicatorView.Style {
        if #available(iOS 12.0, *) {
            if traitCollection.userInterfaceStyle == .light {
                return .gray
            } else {
                return .white
            }
        } else {
            return .gray
        }
    }

    var spinnerPosition: LoadableSpinnerPosition {
        return .center
    }
}
