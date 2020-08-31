//
//  SplashView.swift
//  Notifire
//
//  Created by David Bielik on 12/10/2018.
//  Copyright © 2018 David Bielik. All rights reserved.
//

import UIKit

class SplashView: ConstrainableView {
    
    static let logoWidth: CGFloat = 100
    static let logoAspectRatio: CGFloat = 1.355
    
    let iconImageView: UIImageView = {
        let view = UIImageView(image: #imageLiteral(resourceName: "default_service_image").withRenderingMode(.alwaysTemplate))
        view.tintColor = .white
        return view
    }()
    
    // MARK: - Inherited
    override open func setupSubviews() {
        backgroundColor = .notifireMainColor
        
        add(subview: iconImageView)
        iconImageView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        iconImageView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        iconImageView.widthAnchor.constraint(equalToConstant: SplashView.logoWidth).isActive = true
        iconImageView.heightAnchor.constraint(equalTo: iconImageView.widthAnchor, multiplier: SplashView.logoAspectRatio).isActive = true
    }
}
