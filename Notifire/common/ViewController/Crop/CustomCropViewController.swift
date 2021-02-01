//
//  CustomCropViewController.swift
//  Notifire
//
//  Created by David Bielik on 23/12/2020.
//  Copyright © 2020 David Bielik. All rights reserved.
//

import UIKit
import CropViewController
import SDWebImage

/// CropViewController with custom colors for 'Cancel' and 'Done' buttons.
class CustomCropViewController: CropViewController {

    public var buttonColor: UIColor = .primary {
        didSet {
            toolbar.cancelTextButton.setTitleColor(buttonColor, for: .normal)
            toolbar.doneTextButton.setTitleColor(buttonColor, for: .normal)
        }
    }

    /// `true` if the delegate method received didFinishCancelled
    public var didFinishWithCancel = false

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        // Toolbar Buttons Color
        // Need to keep this in viewWillAppear otherwise the color is not changed.
        buttonColor = .primary
    }
}

/// A customized `CropViewController` that supports GIF cropping and rotation.
/// - Features:
///     - Crop & rotate GIFs
///     - Transparent background GIFs
class GIFCropViewController: CustomCropViewController {

    // MARK: - Properties
    /// The AnimatedImageView that sits in front of `backgroundImageView` and plays the GIF.
    lazy var backgroundAnimatedImageView = SDAnimatedImageView()
    /// The AnimatedImageView that sits in front of `foregroundImageView` and plays the GIF.
    lazy var foregroundAnimatedImageView = SDAnimatedImageView()

    var backgroundImageView: UIImageView? {
        return cropView.subviews.first?.subviews.first?.subviews.first as? UIImageView
    }

    var foregroundImageView: UIImageView? {
        return cropView.subviews.last?.subviews.first as? UIImageView
    }

    var scrollView: UIScrollView? {
        // The cropView should have only one UIScrollView...
        return cropView.subviews.first(where: { $0 is UIScrollView }) as? UIScrollView
    }

    var scrollViewContentOffsetToken: NSKeyValueObservation?
    var backgroundImageViewTransformToken: NSKeyValueObservation?
    var backgroundImageViewAlphaToken: NSKeyValueObservation?
    var foregroundImageViewTransformToken: NSKeyValueObservation?

    // MARK: - Initialization
    deinit {
        scrollViewContentOffsetToken?.invalidate()
        backgroundImageViewTransformToken?.invalidate()
        backgroundImageViewAlphaToken?.invalidate()
        foregroundImageViewTransformToken?.invalidate()
    }

    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        guard
            let backgroundImageView = backgroundImageView,
            let foregroundImageView = foregroundImageView
        else { return }
        // Add animated images views and hide image views
        backgroundImageView.superview?.insertSubview(backgroundAnimatedImageView, aboveSubview: backgroundImageView)
        backgroundImageView.alpha = 0
        foregroundImageView.superview?.insertSubview(foregroundAnimatedImageView, aboveSubview: foregroundImageView)
        foregroundImageView.alpha = 0

        backgroundImageViewTransformToken = backgroundImageView.observe(\.transform, options: .new, changeHandler: { [weak self] (_, change) in
            self?.backgroundAnimatedImageView.transform = change.newValue ?? .identity
        })

        foregroundImageViewTransformToken = foregroundImageView.observe(\.transform, options: .new, changeHandler: { [weak self] (_, change) in
            self?.foregroundAnimatedImageView.transform = change.newValue ?? .identity
        })

        guard let scrollView = scrollView else { return }
        scrollViewContentOffsetToken = scrollView.observe(\.contentOffset, options: .new) { [weak self] (_, _) in
            if let foregroundFrame = self?.foregroundImageView?.frame {
                self?.foregroundAnimatedImageView.frame = foregroundFrame
            }

            if let backgroundFrame = self?.backgroundImageView?.frame {
                self?.backgroundAnimatedImageView.frame = backgroundFrame
            }
        }

        backgroundImageViewAlphaToken = backgroundImageView.observe(\.alpha, options: .new) { (imageView, change) in
            // keep the alpha at 0
            guard let newValue = change.newValue, newValue == 0 else {
                imageView.alpha = 0
                return
            }
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        guard let backgroundImageView = backgroundImageView else { return }
        backgroundAnimatedImageView.frame = backgroundImageView.frame
    }

    // MARK: - Public
    public func set(animatedImage: SDAnimatedImage) {
        backgroundAnimatedImageView.image = animatedImage
        foregroundAnimatedImageView.image = animatedImage
    }
}
