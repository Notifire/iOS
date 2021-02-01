//
//  ImageCropHandler.swift
//  Notifire
//
//  Created by David Bielik on 23/12/2020.
//  Copyright © 2020 David Bielik. All rights reserved.
//

import Foundation
import CropViewController
import SDWebImage
import CoreImage
import MobileCoreServices

class ImageCropHandler: NSObject, CropViewControllerDelegate {

    /// In MB
    private static let maximumFileSize: Double = 8

    weak var imagePicker: ServiceImagePicker?

    func cropViewController(_ cropViewController: CropViewController, didFinishCancelled cancelled: Bool) {
        if let customCropVC = cropViewController as? CustomCropViewController {
            customCropVC.didFinishWithCancel = true
        }
        imagePicker?.finish(result: .cancelled)
    }

    /// Returns `true` if the image size was below limit.
    func checkImageSize(image: UIImage, format: ServiceImagePicker.ImageFormat, cropViewController: CropViewController) -> Bool {

        guard let imageData = try? format.createData(from: image), Double(imageData.count) / 1000 / 1000 <= Self.maximumFileSize else {
            imagePicker?.presentError(title: "Maximum image size reached", message: "The image must be less than 8MB. Please use another one.", presentingViewController: cropViewController, dismissPresenter: false)
            return false
        }
        return true
    }
}

class StaticImageCropHandler: ImageCropHandler {

    private let imageExtension: String

    // MARK: - Initialization
    init(imageExtension: String) {
        self.imageExtension = imageExtension
    }

    func cropViewController(_ cropViewController: CropViewController, didCropImageToRect rect: CGRect, angle: Int) {
        let imageFormat = ServiceImagePicker.ImageFormat(extension: imageExtension)
        let image = cropViewController.image.croppedImage(withFrame: rect, angle: angle, circularClip: false)
        guard checkImageSize(image: image, format: imageFormat, cropViewController: cropViewController) else { return }
        imagePicker?.finish(result: .selected(image: image, format: imageFormat))
    }
}

class GIFImageCropHandler: ImageCropHandler {

    private let imageURL: URL

    // MARK: - Initialization
    init(imageURL: URL) {
        self.imageURL = imageURL
    }

    // MARK: - Private
    private func rotateAndCrop(gifImage: SDAnimatedImage, angle: Int, cropFrame: CGRect) -> Data? {
        let fileProperties = [kCGImagePropertyGIFDictionary as String: [kCGImagePropertyGIFLoopCount as String: 0]]
        // Create mutable data
        let mutableGifData = NSMutableData()
        // Open the data destination -- this should never fail
        guard let destination = CGImageDestinationCreateWithData(mutableGifData, kUTTypeGIF, Int(gifImage.animatedImageFrameCount), nil) else { return nil }
        // Tag the data as a GIF
        CGImageDestinationSetProperties(destination, fileProperties as CFDictionary?)

        // Crop and rotate frame by frame
        for i in 0..<gifImage.animatedImageFrameCount {
            guard let cgImage = gifImage.animatedImageFrame(at: i)?.croppedImage(withFrame: cropFrame, angle: angle, circularClip: false).cgImage else { continue }
            // Make sure the new frame has proper duration
            let gifProperties = [kCGImagePropertyGIFDictionary as String: [kCGImagePropertyGIFDelayTime as String: gifImage.animatedImageDuration(at: i)]]
            // Add it to the mutable data
            CGImageDestinationAddImage(destination, cgImage, gifProperties as CFDictionary?)
        }
        // Finalize the data and return it
        guard CGImageDestinationFinalize(destination) else { return nil }
        return mutableGifData as Data
    }

    // MARK: - CropViewControllerDelegate
    func cropViewController(_ cropViewController: CropViewController, didCropImageToRect rect: CGRect, angle: Int) {
        guard
            let customCropVC = cropViewController as? GIFCropViewController,
            let gifData = try? Data(contentsOf: imageURL),
            let gifImage = SDAnimatedImage(data: gifData),
            let rotatedAndCroppedGifData = rotateAndCrop(gifImage: gifImage, angle: angle, cropFrame: rect),
            let rotatedAndCroppedGifImage = SDAnimatedImage(data: rotatedAndCroppedGifData)
        else {
            imagePicker?.finish(result: .cancelled)
            return
        }
        imagePicker?.finish(result: .selected(image: rotatedAndCroppedGifImage, format: .gif))
    }
}
