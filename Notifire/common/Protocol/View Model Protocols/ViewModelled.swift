//
//  ViewModelled.swift
//  Notifire
//
//  Created by David Bielik on 16/11/2020.
//  Copyright © 2020 David Bielik. All rights reserved.
//

import Foundation

/// ViewControllers containing a ViewModel conform to this protocol.
protocol ViewModelled: class {
    associatedtype ViewModel: ViewModelRepresenting
    var viewModel: ViewModel { get set }

    init(viewModel: ViewModel)
}
