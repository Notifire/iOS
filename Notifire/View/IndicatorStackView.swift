//
//  IndicatorStackView.swift
//  Notifire
//
//  Created by David Bielik on 05/12/2018.
//  Copyright © 2018 David Bielik. All rights reserved.
//

import UIKit

class IndicatorStackView: UIStackView {
    
    private static let circleSeparatorWidth: CGFloat = 2
    private static let spacing: CGFloat = 4
    
    private let textImageView = UIImageView(notifireImage: #imageLiteral(resourceName: "notification_indicator_additional_text"))
    private let circleView: UIView = {
        let view = UIView()
        view.backgroundColor = .spinnerColor
        view.layer.cornerRadius = IndicatorStackView.circleSeparatorWidth/2
        return view
    }()
    private let urlImageView = UIImageView(notifireImage: #imageLiteral(resourceName: "baseline_link_black_48pt"))
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init(coder: NSCoder) { fatalError() }
    
    private func setup() {
        axis = .horizontal
        distribution = .equalSpacing
        spacing = IndicatorStackView.spacing
        alignment = .center
        
        setupArrangedSubviews()
    }
    
    private func add(imageView: UIImageView) {
        addArrangedSubview(imageView)
        imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor).isActive = true
        imageView.widthAnchor.constraint(equalToConstant: Size.Image.indicator).isActive = true
    }
    
    private func setupArrangedSubviews() {
        add(imageView: textImageView)
        addArrangedSubview(circleView)
        circleView.heightAnchor.constraint(equalTo: circleView.widthAnchor).isActive = true
        circleView.widthAnchor.constraint(equalToConstant: IndicatorStackView.circleSeparatorWidth).isActive = true
        add(imageView: urlImageView)
    }
    
    public func set(textVisible: Bool, imageVisible: Bool) {
        textImageView.isHidden = !textVisible
        urlImageView.isHidden = !imageVisible
        circleView.isHidden = !(imageVisible && textVisible)
    }
}
