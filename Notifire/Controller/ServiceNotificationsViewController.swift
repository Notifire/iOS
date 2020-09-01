//
//  ServiceNotificationsViewController.swift
//  Notifire
//
//  Created by David Bielik on 10/11/2018.
//  Copyright © 2018 David Bielik. All rights reserved.
//

import UIKit

class ServiceNotificationsViewController: UITableViewController {

    let viewModel: ServiceNotificationsViewModel

    init(viewModel: ServiceNotificationsViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        setup()
    }

    required init?(coder aDecoder: NSCoder) { fatalError() }

    private func setup() {
        tableView.dontShowEmptyCells()
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.collection.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return UITableViewCell()
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

    }
}
