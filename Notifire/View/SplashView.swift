//
//  SplashView.swift
//  Notifire
//
//  Created by David Bielik on 12/10/2018.
//  Copyright © 2018 David Bielik. All rights reserved.
//

import UIKit

class SplashView: ConstrainableView {

    static let logoWidth: CGFloat = 100
    static let logoAspectRatio: CGFloat = 1.355

    let iconImageView: UIImageView = {
        let imageView = UIImageView(image: #imageLiteral(resourceName: "default_white_service_image").withRenderingMode(.alwaysTemplate))
        imageView.tintColor = .white
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    // MARK: - Inherited
    override open func setupSubviews() {
        backgroundColor = .primary

//        let opaqueView = UIView()
//        opaqueView.backgroundColor = .primary
//        add(subview: opaqueView)
//        opaqueView.embed(in: self)

        add(subview: iconImageView)
        iconImageView.centerXAnchor.constraint(equalTo: safeAreaLayoutGuide.centerXAnchor).isActive = true
        iconImageView.centerYAnchor.constraint(equalTo: safeAreaLayoutGuide.centerYAnchor).isActive = true
        iconImageView.widthAnchor.constraint(equalToConstant: SplashView.logoWidth).isActive = true
        iconImageView.heightAnchor.constraint(equalTo: iconImageView.widthAnchor, multiplier: SplashView.logoAspectRatio).isActive = true

//        let maskFrame = CGRect(x: 100, y: 200, width: 300, height: 600)
//        opaqueView.layer.mask = CALayer()
//        opaqueView.layer.mask?.contents = invertMask(#imageLiteral(resourceName: "baseline_notifications_black_48pt"))?.cgImage
//        opaqueView.layer.mask?.bounds = maskFrame
//        opaqueView.layer.mask?.anchorPoint = CGPoint(x: 0.5, y: 0.5)
//        opaqueView.layer.mask?.position = CGPoint(x: maskFrame.width / 2, y: maskFrame.height / 2)

    }

    func invertMask(_ image: UIImage) -> UIImage? {
        guard let inputMaskImage = CIImage(image: image),
            let backgroundImageFilter = CIFilter(name: "CIConstantColorGenerator", parameters: [kCIInputColorKey: CIColor.black]),
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
