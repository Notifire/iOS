//
//  VMViewController.swift
//  Notifire
//
//  Created by David Bielik on 01/09/2020.
//  Copyright © 2020 David Bielik. All rights reserved.
//

import UIKit

/// ViewController base class with dependency injection for a generic ViewModel
class VMViewController<ViewModel: ViewModelRepresenting>: UIViewController, ViewModelled {

    var viewModel: ViewModel

    init(viewModel: ViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { fatalError("VMViewController init from coder not implemented") }
}
