//
//  UIActivityIndicatorView+Init.swift
//  Notifire
//
//  Created by David Bielik on 19/11/2020.
//  Copyright © 2020 David Bielik. All rights reserved.
//

import UIKit

extension UIActivityIndicatorView {

    /// Create a standard loading indicator.
    static var loadingIndicator: UIActivityIndicatorView {
        let style: UIActivityIndicatorView.Style
        if #available(iOS 13.0, *) {
            style = .medium
        } else {
            style = .gray
        }
        let control = UIActivityIndicatorView(style: style)
        control.hidesWhenStopped = true
        control.startAnimating()
        return control
    }
}
