//
//  DeeplinkHandler.swift
//  Notifire
//
//  Created by David Bielik on 19/10/2018.
//  Copyright © 2018 David Bielik. All rights reserved.
//

import UIKit
import GoogleSignIn

class DeeplinkHandler {

    var currentDeeplink: Deeplink?
    weak var appCoordinator: AppCoordinator?

    // MARK: - Private
    enum URLOrigin {
        case google
        case notifire
    }

    private func determineURLOrigin(url: URL) -> URLOrigin {
        if url.host?.contains("google") ?? false {
            return .google
        } else {
            return .notifire
        }
    }

    // MARK: Handlers
    private func handleAppropriateNotifireDeeplink(from url: URL) -> Bool {
        var comp = url.pathComponents
        guard !comp.isEmpty else {
            return false
        }

        let token = comp.removeLast()
        switch comp {
        case ["/", "account", "confirm"]:
            switchTo(deeplinkOption: .accountConfirmation(token: token))
        case ["/", "account", "reset", "email"]:
            switchTo(deeplinkOption: .changeEmail(token: token))
        case ["/", "account", "reset", "password"]:
            switchTo(deeplinkOption: .resetPassword(token: token))
        default:
            // unknown url format
            return false
        }
        return true
    }

    private func handleGoogleDeeplink(from url: URL) -> Bool {
        return GIDSignIn.sharedInstance().handle(url)
    }

    // MARK: - Internal
    func switchToAppropriateDeeplink(from url: URL) -> Bool {
        switch determineURLOrigin(url: url) {
        case .google: return handleGoogleDeeplink(from: url)
        case .notifire: return handleAppropriateNotifireDeeplink(from: url)
        }
    }

    func createDeeplinkableVC<VC: DeeplinkedVMViewController<VM>, VM: UserSessionCreating & DeeplinkResponding>(viewControllerType: VC.Type, token: String) -> DeeplinkedVMViewController<VM> {
        let viewModel = viewControllerType.ViewModel.init(apiManager: NotifireAPIFactory.createAPIManager(), token: token)
        viewModel.sessionDelegate = appCoordinator
        let viewController = viewControllerType.init(viewModel: viewModel)
        viewController.delegate = appCoordinator
        return viewController
    }

    func switchTo(deeplinkOption: Deeplink.Option) {
        // dismiss any presented deeplink
        if currentDeeplink != nil {
            finishDeeplink(animated: false)
        }
        // handle the new deeplink option
        let newDeeplink = Deeplink(option: deeplinkOption, presenter: appCoordinator?.window.rootViewController)
        let deeplinkViewController: UIViewController
        switch deeplinkOption {
        case .accountConfirmation(let token):
            deeplinkViewController = createDeeplinkableVC(viewControllerType: DLConfirmAccountViewController.self, token: token)
        case .changeEmail:
            deeplinkViewController = UIViewController()
        case .resetPassword(let token):
            deeplinkViewController = createDeeplinkableVC(viewControllerType: DLResetPasswordViewController.self, token: token)
        case .changEmailRevert:
            deeplinkViewController = UIViewController()
        }
        let wrapper = NotifireNavigationController(rootViewController: deeplinkViewController)
        if #available(iOS 13.0, *) {
            wrapper.isModalInPresentation = true
        }
        newDeeplink.deeplinkPresenter.present(wrapper, animated: true, completion: nil)
        self.currentDeeplink = newDeeplink
    }

    func finishDeeplink(animated: Bool = true, completion: (() -> Void)? = nil) {
        guard let activeDeeplink = currentDeeplink else {
            completion?()
            return
        }
        activeDeeplink.deeplinkPresenter.presentedViewController?.dismiss(animated: animated, completion: {
            if self.currentDeeplink?.option == activeDeeplink.option {
                self.currentDeeplink = nil
            }
            completion?()
        })
    }
}
