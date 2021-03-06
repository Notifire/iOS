//
//  RoundedImageView.swift
//  Notifire
//
//  Created by David Bielik on 17/11/2018.
//  Copyright © 2018 David Bielik. All rights reserved.
//

import UIKit
import SkeletonView
import SDWebImage

class RoundedImageView: SDAnimatedImageView {

    override init(frame: CGRect = .zero) {
        super.init(frame: frame)
        setup()
    }

    override init(image: UIImage?) {
        super.init(image: image)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    private func setup() {
        isSkeletonable = true
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = bounds.width/2
        layer.masksToBounds = true
        skeletonCornerRadius = Float(bounds.width / 2)
        clipsToBounds = true
    }

    override func sd_setImage(with url: URL?, placeholderImage placeholder: UIImage?, options: SDWebImageOptions = [], context: [SDWebImageContextOption: Any]?, progress progressBlock: SDImageLoaderProgressBlock?, completed completedBlock: SDExternalCompletionBlock? = nil) {
        let newPlaceholder = image == nil ? placeholder : image
        sd_imageIndicator = SDWebImageActivityIndicator.gray
        super.sd_setImage(with: url, placeholderImage: newPlaceholder, options: options, context: context, progress: progressBlock, completed: completedBlock)
    }
}

class RoundedContainerImageView: ConstrainableView {
    let roundedImageView: RoundedImageView

    var image: UIImage? {
        get {
            return roundedImageView.image
        }
        set {
            roundedImageView.image = newValue
            setNeedsDisplay()
        }
    }

    init(image: UIImage?) {
        roundedImageView = RoundedImageView(image: image)
        super.init()
    }

    required init?(coder aDecoder: NSCoder) { fatalError() }

    override func setupSubviews() {
        isSkeletonable = true
        layout()
    }

    private func layout() {
        add(subview: roundedImageView)
        roundedImageView.embed(in: self)
    }
}

class RoundedActionButton: ActionButton {

    override open var isHighlighted: Bool {
        didSet {
            backgroundColor = isHighlighted ? UIColor.primary.withAlphaComponent(0.3) : .compatibleSystemBackground
        }
    }

    override func setup() {
        super.setup()

        translatesAutoresizingMaskIntoConstraints = false
        tintColor = .white
        backgroundColor = .compatibleSystemBackground

        imageView?.contentMode = .scaleAspectFit
        imageView?.backgroundColor = .primary
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        // Round the corners of edit button
        layer.cornerRadius = frame.width / 2
        layer.masksToBounds = true
        imageEdgeInsets = .init(everySide: frame.width / 3.4)

        // Round the corners of edit button image
        if let imageView = imageView {
            imageView.layer.cornerRadius = imageView.frame.width / 2
        }
    }
}

class RoundedEditableImageView: RoundedContainerImageView, UIGestureRecognizerDelegate {

    enum ImageEditStyle {
        case add
        case edit

        var image: UIImage {
            switch self {
            case .add: return UIImage(imageLiteralResourceName: "plus")
            case .edit: return UIImage(imageLiteralResourceName: "pencil")
            }
        }

        var height: CGFloat {
            switch self {
            case .add: return Size.Image.normalService * 0.8
            case .edit: return Size.Image.smallService
            }
        }
    }

    // MARK: - Properties
    var imageEditStyle: ImageEditStyle = .add {
        didSet {
            editButton.setImage(imageEditStyle.image.withRenderingMode(.alwaysTemplate), for: .normal)
            setNeedsLayout()
        }
    }

    weak var imageHighlightOverlayLayer: CALayer?

    // MARK: Static
    static let allowedMovementOffset: CGFloat = 8

    // MARK: UI
    lazy var editButton: RoundedActionButton = {
        let button = RoundedActionButton(type: .system)
        button.setImage(imageEditStyle.image.withRenderingMode(.alwaysTemplate), for: .normal)
        button.onProperTap = { [unowned self] _ in
            self.onUserAction?()
        }
        return button
    }()

    // MARK: Callback
    /// Called whenever the user taps the editButton or taps/long presses the RoundedImageView
    var onUserAction: (() -> Void)?

    // MARK: - Inherited
    override func setupSubviews() {
        super.setupSubviews()

        // Gesture Recognizer
        let longPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(didLongPressImageView))
        longPressGestureRecognizer.minimumPressDuration = 0
        longPressGestureRecognizer.allowableMovement = 8
        longPressGestureRecognizer.delegate = self
        addGestureRecognizer(longPressGestureRecognizer)

        // Border
        for layer in [roundedImageView.layer, editButton.layer] {
            layer.borderWidth = 1
            layer.borderColor = UIColor.customSeparator.cgColor
        }

        // Layout
        add(subview: editButton)
        editButton.widthAnchor.constraint(equalToConstant: imageEditStyle.height).isActive = true
        editButton.heightAnchor.constraint(equalTo: editButton.widthAnchor).isActive = true
    }

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        return touch.view !== editButton
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        // Compute the position for editButton
        let theta: CGFloat = CGFloat.pi * 45 / 180
        let radius = bounds.width / 2
        let x: CGFloat = bounds.width / 2 + radius * cos(theta) - editButton.frame.width / 2
        let y: CGFloat = bounds.width / 2 + radius * sin(theta) - editButton.frame.width / 2
        let editButtonOrigin = CGPoint(x: x, y: y)
        editButton.frame = CGRect(origin: editButtonOrigin, size: editButton.frame.size)
    }

    @objc private func didLongPressImageView(_ gestureRecognizer: UILongPressGestureRecognizer) {
        switch gestureRecognizer.state {
        case .began:
            // Add overlay
            guard imageHighlightOverlayLayer == nil else { return }
            let overlayLayer = CALayer()
            overlayLayer.frame = roundedImageView.frame.insetBy(dx: -10, dy: -10)
            overlayLayer.backgroundColor = UIColor.compatibleGray.withAlphaComponent(0.25).cgColor
            overlayLayer.cornerRadius = overlayLayer.frame.width / 2
            layer.insertSublayer(overlayLayer, below: editButton.layer)
            imageHighlightOverlayLayer = overlayLayer
        case .ended:
            // Remove overlay and execute action
            if let overlayLayer = imageHighlightOverlayLayer {
                overlayLayer.removeFromSuperlayer()
                onUserAction?()
                imageHighlightOverlayLayer = nil
            }
        case .changed:
            let location = gestureRecognizer.location(in: self)
            if location.x < -Self.allowedMovementOffset || location.x > bounds.width + Self.allowedMovementOffset ||
                location.y < -Self.allowedMovementOffset || location.y > bounds.height + Self.allowedMovementOffset {
                imageHighlightOverlayLayer?.removeFromSuperlayer()
                imageHighlightOverlayLayer = nil
            }
        case .cancelled, .failed:
            // Remove overlay
            imageHighlightOverlayLayer?.removeFromSuperlayer()
            imageHighlightOverlayLayer = nil
        default:
            break
        }
    }
}

class RoundedEmojiImageView: RoundedContainerImageView {

    private var topConstraint: NSLayoutConstraint!
    private var trailingConstraint: NSLayoutConstraint!

    enum EmojiSize {
        case compact
        case normal
    }

    let emojiSize: EmojiSize

    let label: UILabel = {
        let label = UILabel(style: .emoji)
        label.layer.shadowRadius = 2
        label.layer.shadowOffset = CGSize(width: -1, height: 1)
        label.layer.shadowColor = UIColor.black.cgColor
        label.layer.shadowOpacity = 1
        return label
    }()

    init(image: UIImage?, size: EmojiSize = .compact) {
        self.emojiSize = size
        super.init(image: image)
    }

    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func setupSubviews() {
        super.setupSubviews()
        roundedImageView.contentMode = .scaleAspectFit
        layout()
    }

    func set(level: NotificationLevel) {
        label.text = level.emoji
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        let fontSize: CGFloat
        let offset: CGFloat
        switch emojiSize {
        case .compact:
            offset = bounds.width / 16
            fontSize = bounds.width / 3
        case .normal:
            offset = 0
            fontSize = bounds.width / 2.5
        }
        label.font = label.font.withSize(fontSize)

        topConstraint.constant = -offset
        trailingConstraint.constant = offset
    }

    private func layout() {
        add(subview: label)
        topConstraint = label.topAnchor.constraint(equalTo: topAnchor)
        topConstraint.isActive = true

        trailingConstraint = label.trailingAnchor.constraint(equalTo: trailingAnchor)
        trailingConstraint.isActive = true
    }
}

class RoundedShadowImageView: RoundedContainerImageView {

    // MARK: - Properties
    /// The shadow layer.
    var shadowLayer: CALayer?
    /// The layer that contains the shadow layer.
    /// - Note: This layer is crucial to mask the shadow properly under transparent images. Do not remove / modify it.
    var shadowOpaqueLayer: CALayer?

    // MARK: - Overrides
    override func setupSubviews() {
        super.setupSubviews()
        backgroundColor = .clear

        // Create opaque layer
        let shadowOpaqueLayer = CALayer()
        shadowOpaqueLayer.backgroundColor = UIColor.black.cgColor
        self.shadowOpaqueLayer = shadowOpaqueLayer

        // Create shadow layer
        let shadowLayer = CALayer()

        shadowLayer.backgroundColor = UIColor.black.cgColor
        shadowLayer.shadowRadius = 8
        shadowLayer.shadowOpacity = 0.4
        shadowLayer.shadowOffset = CGSize(width: 0, height: 1)
        self.shadowLayer = shadowLayer
        shadowOpaqueLayer.insertSublayer(shadowLayer, at: 0)

        // Insert shadow opaque layer
        layer.insertSublayer(shadowOpaqueLayer, at: 0)
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        guard let shadowLayer = shadowLayer, let shadowOpaqueLayer = shadowOpaqueLayer else { return }
        shadowOpaqueLayer.frame = bounds
        shadowOpaqueLayer.cornerRadius = shadowOpaqueLayer.frame.width/2
        shadowLayer.frame = shadowOpaqueLayer.bounds
        shadowLayer.cornerRadius = shadowLayer.frame.width/2

        // Create path that will mask the shadow
        let path = CGMutablePath()
        path.addRect(bounds.insetBy(dx: -16, dy: -16))
        path.addPath(UIBezierPath(ovalIn: shadowLayer.bounds).cgPath)

        let shape = CAShapeLayer()
        shape.path = path
        shape.fillRule = .evenOdd
        shadowOpaqueLayer.mask = shape
    }
}
