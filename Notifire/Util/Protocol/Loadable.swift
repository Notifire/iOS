//
//  Loadable.swift
//  Notifire
//
//  Created by David Bielik on 13/10/2018.
//  Copyright © 2018 David Bielik. All rights reserved.
//

import UIKit

private class LoadableSpinner: UIActivityIndicatorView {}

enum LoadableSpinnerPosition {
    case center
    case right
    case under
}

protocol Loadable: class {
    var spinnerSuperview: UIView { get }
    var spinnerStyle: UIActivityIndicatorView.Style { get }
    var spinnerPosition: LoadableSpinnerPosition { get }

    func startLoading() -> UIActivityIndicatorView?
    func stopLoading()
    func onLoadingStart()
    func onLoadingFinished()
}

extension Loadable {
    var spinnerStyle: UIActivityIndicatorView.Style {
        return .gray
    }

    var spinnerPosition: LoadableSpinnerPosition {
        return .right
    }

    func onLoadingStart() {}     // optional
    func onLoadingFinished() {}  // optional

    private func activeSpinner() -> LoadableSpinner? {
        let maybeSpinner = spinnerSuperview.subviews.first { $0 is LoadableSpinner }
        return maybeSpinner as? LoadableSpinner
    }

    @discardableResult
    func startLoading() -> UIActivityIndicatorView? {
        let maybeActive = activeSpinner()
        guard maybeActive == nil else { return nil }
        let spinner = LoadableSpinner(style: spinnerStyle)
        spinnerSuperview.add(subview: spinner)
        switch spinnerPosition {
        case .right:
            spinner.leadingAnchor.constraint(equalTo: spinnerSuperview.trailingAnchor, constant: 8).isActive = true
            spinner.centerYAnchor.constraint(equalTo: spinnerSuperview.centerYAnchor).isActive = true
        case .center:
            spinner.centerXAnchor.constraint(equalTo: spinnerSuperview.centerXAnchor).isActive = true
            spinner.centerYAnchor.constraint(equalTo: spinnerSuperview.centerYAnchor).isActive = true
        case .under:
            spinner.centerXAnchor.constraint(equalTo: spinnerSuperview.centerXAnchor).isActive = true
            spinner.topAnchor.constraint(equalTo: spinnerSuperview.bottomAnchor, constant: 8).isActive = true
        }
        spinner.startAnimating()
        onLoadingStart()
        return spinner
    }

    func stopLoading() {
        let maybeSpinner = activeSpinner()
        guard let activeSpinner = maybeSpinner else { return }
        activeSpinner.removeFromSuperview()
        onLoadingFinished()
    }

    func changeLoading(to loading: Bool) {
        if loading {
            _ = startLoading()
        } else {
            stopLoading()
        }
    }
}

extension Loadable where Self: UIView {
    var spinnerSuperview: UIView {
        return self
    }
}

extension Loadable where Self: UIControl {
    func onLoadingStart() {
        isEnabled = false
    }

    func onLoadingFinished() {
        isEnabled = true
    }
}
