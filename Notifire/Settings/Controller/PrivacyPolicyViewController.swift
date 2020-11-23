//
//  PrivacyPolicyViewController.swift
//  Notifire
//
//  Created by David Bielik on 23/11/2020.
//  Copyright © 2020 David Bielik. All rights reserved.
//

import UIKit
import WebKit

class PrivacyPolicyViewController: UIViewController, Loadable, APIErrorPresenting {

    // MARK: - Properties
    // MARK: Model
    lazy var request = URLRequest(url: Config.privacyPolicyURL)

    let loading = LoadingModel()

    // MARK: UI
    lazy var webView = WKWebView()

    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .compatibleSystemBackground

        layout()

        loading.onLoadingChange = { [weak self] loading in
            if loading {
                self?.startLoading()
            } else {
                self?.stopLoading()
            }
        }

        // Load the privacy policy
        webView.navigationDelegate = self
        loadWebView()
    }

    // MARK: - Private
    private func layout() {
        view.add(subview: webView)
        webView.embed(in: view)
    }

    /// Start loading the webView contents
    private func loadWebView() {
        loading.isLoading = true
        webView.load(request)
    }

    /// Handler for Errors from webView loading
    private func onError(_ error: Error) {
        loading.isLoading = false
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(didSelectRefreshButton))
        present(error: .urlSession(error: error))
    }

    @objc private func didSelectRefreshButton() {
        webView.load(request)
        navigationItem.rightBarButtonItem = nil
    }
}

// MARK: - PrivacyPolicyViewController+WKNavigationDelegate
extension PrivacyPolicyViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        onError(error)
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        loading.isLoading = false
    }

    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        loading.isLoading = true
    }

    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        onError(error)
    }
}
