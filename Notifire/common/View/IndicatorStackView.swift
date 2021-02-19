//
//  IndicatorStackView.swift
//  Notifire
//
//  Created by David Bielik on 05/12/2018.
//  Copyright © 2018 David Bielik. All rights reserved.
//

import UIKit

extension UIImageView {
    /// Create a `UIImageView` that prefers iOS 13+ SFSymbols but falls back to UIImage for lower iOS versions.
    convenience init(systemName: String, compatibleNotifireImage: UIImage, tintColor: UIColor = .spinnerColor) {
        self.init()
        let image: UIImage?
        if #available(iOS 13, *) {
            let imageConfig = UIImage.SymbolConfiguration(pointSize: Size.Image.indicator * 3/4)
            image = UIImage(systemName: systemName, withConfiguration: imageConfig)
        } else {
            image = compatibleNotifireImage.resized(to: CGSize(equal: Size.Image.indicator))
        }
        self.image = image?.withRenderingMode(.alwaysTemplate)
        self.tintColor = tintColor
    }
}

class IndicatorStackView: UIStackView {

    // MARK: - Properties
    // MARK: Static
    private static let circleSeparatorWidth: CGFloat = 2
    private static let spacing: CGFloat = 4

    // MARK: UI
    private lazy var textImageView = UIImageView(systemName: "doc.plaintext", compatibleNotifireImage: #imageLiteral(resourceName: "doc.plaintext"))

    private lazy var circleView: UIView = {
        let view = UIView()
        view.backgroundColor = .spinnerColor
        view.layer.cornerRadius = IndicatorStackView.circleSeparatorWidth/2
        return view
    }()

    private lazy var urlImageView = UIImageView(systemName: "link", compatibleNotifireImage: #imageLiteral(resourceName: "link"))

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init(coder: NSCoder) { fatalError() }

    override func layoutSubviews() {
        super.layoutSubviews()
        circleView.frame = CGRect(origin: circleView.frame.origin, size: CGSize(equal: Self.circleSeparatorWidth))
    }

    private func setup() {
        axis = .horizontal
        distribution = .equalSpacing
        spacing = IndicatorStackView.spacing
        alignment = .center

        setupArrangedSubviews()
    }

    private func setupArrangedSubviews() {
        addArrangedSubview(textImageView)
        addArrangedSubview(circleView)
        addArrangedSubview(urlImageView)
    }

    public func set(textVisible: Bool, imageVisible: Bool) {
        textImageView.isHidden = !textVisible
        urlImageView.isHidden = !imageVisible
        circleView.isHidden = !(imageVisible && textVisible)
    }
}
