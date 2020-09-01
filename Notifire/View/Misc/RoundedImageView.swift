//
//  RoundedImageView.swift
//  Notifire
//
//  Created by David Bielik on 17/11/2018.
//  Copyright © 2018 David Bielik. All rights reserved.
//

import UIKit

class RoundedImageView: UIImageView {

    var activeShadowPath: CGPath?

    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = bounds.width/2
        clipsToBounds = true
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
        }
    }

    init(image: UIImage?) {
        roundedImageView = RoundedImageView(image: image)
        super.init()
    }

    required init?(coder aDecoder: NSCoder) { fatalError() }

    override func setupSubviews() {
        layout()
    }

    private func layout() {
        add(subview: roundedImageView)
        roundedImageView.embed(in: self)
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

    override func setupSubviews() {
        layer.shadowRadius = 8
        layer.shadowOpacity = 0.4
        layer.shadowOffset = .zero
        super.setupSubviews()
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        layer.shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: bounds.width/2).cgPath
    }
}
