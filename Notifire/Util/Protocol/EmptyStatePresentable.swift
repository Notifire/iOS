//
//  EmptyStatePresentable.swift
//  Notifire
//
//  Created by David Bielik on 13/12/2018.
//  Copyright © 2018 David Bielik. All rights reserved.
//

import UIKit

/// Represents classes that can present an empty state.
protocol EmptyStatePresentable: class {
    /// The type of the view that will be the empty state view.
    associatedtype EmptyStateView: UIView
    /// The empty state view that is currently presented. Otherwise nil.
    var emptyStateView: EmptyStateView? { get set }

    /// The default view that will be below the EmptyStateView.
    /// - Note: The empty state view will be embedded into this view.
    var viewToHideWithEmptyState: UIView { get }

    /// Add the empty state above the `viewToHide`.
    func addEmptyStateView() -> EmptyStateView?
    /// Remove the empty state.
    func removeEmptyStateView()
}

extension EmptyStatePresentable where Self: UIViewController {
    @discardableResult
    func addEmptyStateView() -> EmptyStateView? {
        guard emptyStateView == nil else { return nil }
        let empty = EmptyStateView()
        emptyStateView = empty
        view.insertSubview(empty, aboveSubview: viewToHideWithEmptyState)
        empty.embed(in: viewToHideWithEmptyState)
        return emptyStateView
    }

    func removeEmptyStateView() {
        emptyStateView?.removeFromSuperview()
        emptyStateView = nil
    }

    var viewToHideWithEmptyState: UIView {
        return view
    }
}

class ErrorEmptyStateView: ConstrainableView {

    // MARK: - Properties
    var onTap: (() -> Void)? {
        didSet {
            messageLabel.isHidden = onTap == nil
        }
    }

    // MARK: UI
    lazy var titleLabel = UILabel(style: .alertInformation, text: "Network error encountered")
    lazy var messageLabel = UILabel(style: .centeredLightInformation, text: "Tap to retry.")

    // MARK: - View Lifecycle
    override func setupSubviews() {
        super.setupSubviews()

        backgroundColor = .compatibleSystemBackground

        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTapView)))

        layout()
    }

    // MARK: - Private
    private func layout() {
        add(subview: titleLabel)
        titleLabel.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        titleLabel.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true

        add(subview: messageLabel)
        messageLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: Size.textFieldSpacing).isActive = true
        messageLabel.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
    }

    @objc private func didTapView() {
        UIView.animate(withDuration: 0.15, delay: 0, options: [.beginFromCurrentState, .allowUserInteraction], animations: {
            self.backgroundColor = .compatibleBackgroundAccent
        }, completion: { [weak self] _ in
            self?.onTap?()
            UIView.animate(withDuration: 0.1) {
                self?.backgroundColor = .compatibleSystemBackground
            }
        })
    }
}

protocol ErrorStateError: Error {
    var errorTitle: String { get }
    var errorMessage: String? { get }
    /// Whether a retry button for this error is needed
    var shouldDisplayRetryButton: Bool { get }
}

protocol ErrorStatePresentable: EmptyStatePresentable where EmptyStateView == ErrorEmptyStateView {
    /// Add an error state view.
    /// - Parameters:
    ///     - title: The title displayed in the error view.
    ///     - onRetry: Called whenever the user taps the error view. IF thi parameter is nil, the view isn't tappable.
    func addErrorStateView(title: String, onRetry: (() -> Void)?)
}

extension ErrorStatePresentable {
    func addErrorStateView(title: String, onRetry: (() -> Void)?) {
        guard let errorStateView = addEmptyStateView() else { return }
        errorStateView.onTap = onRetry
        errorStateView.titleLabel.text = title
    }
}
