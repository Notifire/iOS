//
//  ChoiceSeparatorView.swift
//  Notifire
//
//  Created by David Bielik on 09/11/2018.
//  Copyright © 2018 David Bielik. All rights reserved.
//

import UIKit

class ChoiceSeparatorView: ConstrainableView {

    let hairlineView = HairlineView()

    let choiceLabel: UILabel = {
        let label = UILabel(style: UILabel.Style.centeredLightInformation)
        label.text = "or"
        label.backgroundColor = .clear
        return label
    }()

    override var intrinsicContentSize: CGSize {
        return CGSize(width: UIView.noIntrinsicMetric, height: 40)
    }

    override func setupSubviews() {
        add(subview: hairlineView)
        hairlineView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        hairlineView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        hairlineView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        hairlineView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true

        add(subview: choiceLabel)
        choiceLabel.centerXAnchor.constraint(equalTo: hairlineView.centerXAnchor).isActive = true
        choiceLabel.centerYAnchor.constraint(equalTo: hairlineView.centerYAnchor).isActive = true
        choiceLabel.widthAnchor.constraint(equalToConstant: 50).isActive = true
        choiceLabel.backgroundColor = .compatibleSystemBackground

    }
}
