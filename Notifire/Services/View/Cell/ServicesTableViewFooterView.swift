//
//  ServicesTableViewFooterView.swift
//  Notifire
//
//  Created by David Bielik on 02/10/2020.
//  Copyright © 2020 David Bielik. All rights reserved.
//

import UIKit

class ServicesTableViewFooterView: ReusableHeaderFooter {

    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    private func setup() {
        let bgView = UIView()
        bgView.backgroundColor = .clear
        backgroundView = bgView
    }
}
