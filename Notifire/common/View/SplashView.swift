//
//  SplashView.swift
//  Notifire
//
//  Created by David Bielik on 12/10/2018.
//  Copyright © 2018 David Bielik. All rights reserved.
//

import UIKit

class SplashView: ConstrainableView {

    // MARK: - Properties
    static let logoWidth: CGFloat = 100
    static let logoAspectRatio: CGFloat = 1.355

    private lazy var image: UIImage = #imageLiteral(resourceName: "default_white_service_image").withRenderingMode(.alwaysTemplate)
    private lazy var splashImage: UIImage? = invertMask(image)

    /// The ImageView containing an opaque icon image.
    /// Used for filling out the masked
    lazy var iconImageView: UIImageView = {
        let imageView = UIImageView(image: image)
        imageView.tintColor = .white
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    /// The view that has a `.primary` background color and a CGRect of the size of `iconImageView` cut out in the middle
    let primaryBackgroundRectHoleView = UIView()

    // MARK: - Inherited
    override open func setupSubviews() {
        backgroundColor = .primary
//        transform = .init(scaleX: 4, y: 4)
//        isUserInteractionEnabled = false
        add(subview: iconImageView)
        iconImageView.centerXAnchor.constraint(equalTo: safeAreaLayoutGuide.centerXAnchor).isActive = true
        iconImageView.centerYAnchor.constraint(equalTo: safeAreaLayoutGuide.centerYAnchor).isActive = true
        iconImageView.widthAnchor.constraint(equalToConstant: SplashView.logoWidth).isActive = true
        iconImageView.heightAnchor.constraint(equalTo: iconImageView.widthAnchor, multiplier: SplashView.logoAspectRatio).isActive = true
//
//        add(subview: primaryBackgroundRectHoleView)
//        primaryBackgroundRectHoleView.embed(in: self)
//        primaryBackgroundRectHoleView.backgroundColor = .primary
    }

//    override func draw(_ rect: CGRect) {
//        // Draw the inverted mask image
//        //splashImage?.draw(in: iconImageView.frame)
//
//        super.draw(rect)
//
////        image.draw(in: iconImageView.frame, blendMode: CGBlendMode.destinationOut, alpha: 1)
//
//    }

    override func layoutSubviews() {
        super.layoutSubviews()
//
//        let maskLayer = CAShapeLayer()
//        maskLayer.allowsEdgeAntialiasing = true
//        maskLayer.frame = primaryBackgroundRectHoleView.frame
//        // Rectangle in which circle will be drawn
//        let rect = iconImageView.frame
//        let rectPath = UIBezierPath(rect: rect)
//        // Create a path
//        let path = UIBezierPath(rect: primaryBackgroundRectHoleView.bounds)
//        // Append additional path which will create a circle
//        path.append(rectPath)
//        // Setup the fill rule to EvenOdd to properly mask the specified area and make a crater
//        maskLayer.fillRule = CAShapeLayerFillRule.evenOdd
//        // Append the circle to the path so that it is subtracted.
//        maskLayer.path = path.cgPath
//        // Mask our view with Blue background so that portion of red background is visible
//        primaryBackgroundRectHoleView.layer.mask = maskLayer
    }

    func invertMask(_ image: UIImage) -> UIImage? {
        guard let inputMaskImage = CIImage(image: image),
            let backgroundImageFilter = CIFilter(name: "CIConstantColorGenerator", parameters: [kCIInputColorKey: CIColor(color: .primary)]),
            let inputColorFilter = CIFilter(name: "CIConstantColorGenerator", parameters: [kCIInputColorKey: CIColor.clear]),
            let inputImage = inputColorFilter.outputImage,
            let backgroundImage = backgroundImageFilter.outputImage,
            let filter = CIFilter(name: "CIBlendWithAlphaMask", parameters: [kCIInputImageKey: inputImage, kCIInputBackgroundImageKey: backgroundImage, kCIInputMaskImageKey: inputMaskImage]),
            let filterOutput = filter.outputImage,
            let outputImage = CIContext().createCGImage(filterOutput, from: inputMaskImage.extent) else { return nil }
        let finalOutputImage = UIImage(cgImage: outputImage)
        return finalOutputImage
    }

}
