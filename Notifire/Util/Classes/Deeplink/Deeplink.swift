//
//  Deeplink.swift
//  Notifire
//
//  Created by David Bielik on 19/10/2018.
//  Copyright © 2018 David Bielik. All rights reserved.
//

import UIKit

class Deeplink {

    enum Option: Equatable {
        case emailConfirmation(token: String)
        case resetPassword(token: String)
        case resetEmail(token: String)
    }

    let option: Option
    let window: UIWindow?
    let deeplinkPresenter: UIViewController

    init(option: Option, presenter: UIViewController?) {
        self.option = option

        if #available(iOS 13.0, *), let presenter = presenter {
            // No need to use a new UIWindow to present the Deeplink on iOS 13.0+
            // because you can't open a deeplink while a system alert is present.
            self.deeplinkPresenter = presenter
            self.window = nil
        } else {
            let newWindow = UIWindow(frame: UIScreen.main.bounds)
            let vc = UIViewController()
            newWindow.rootViewController = vc
            newWindow.windowLevel = UIWindow.Level.alert + 1
            newWindow.makeKeyAndVisible()
            self.deeplinkPresenter = vc
            self.window = newWindow
        }
    }
}
