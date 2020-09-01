//
//  SettingsViewController.swift
//  Notifire
//
//  Created by David Bielik on 12/10/2018.
//  Copyright © 2018 David Bielik. All rights reserved.
//

import UIKit

protocol SettingsViewControllerDelegate: class {
    func didTapLogoutButton()
}

class SettingsViewController: UIViewController {

    // MARK: - Properties
    weak var delegate: SettingsViewControllerDelegate?

    // MARK: Views
    lazy var logoutButton: ActionButton = {
        let button = ActionButton(type: .system)
        button.setTitle("logout", for: .normal)
        button.onProperTap = { [unowned self] in
            self.promptLogout()
        }
        return button
    }()

    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .backgroundColor

        layout()
    }

    // MARK: - Private
    private func layout() {
        view.add(subview: logoutButton)
        logoutButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        logoutButton.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
    }

    private func promptLogout() {
        let logoutAlert = UIAlertController(title: "Logout from Notifire?", message: "Are you sure? You won't receive any notifications after logging out.", preferredStyle: .alert)
        logoutAlert.addAction(UIAlertAction(title: "Yes", style: .cancel, handler: { _ in
            self.delegate?.didTapLogoutButton()
        }))
        logoutAlert.addAction(UIAlertAction(title: "No", style: .default, handler: { _ in
            logoutAlert.dismiss(animated: true, completion: nil)
        }))
        present(logoutAlert, animated: true, completion: nil)
    }
}
