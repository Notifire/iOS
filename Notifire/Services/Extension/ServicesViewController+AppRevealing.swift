//
//  ServicesViewController+AppRevealing.swift
//  Notifire
//
//  Created by David Bielik on 02/10/2020.
//  Copyright © 2020 David Bielik. All rights reserved.
//

import Foundation

extension ServicesViewController: AppRevealing {
    func customRevealContentCompletion() -> Bool {
        // ViewModel entrypoint
        viewModel.start()

        // completed
        return true
    }
}
