//
//  ServiceImagePicker.swift
//  Notifire
//
//  Created by David Bielik on 23/12/2020.
//  Copyright © 2020 David Bielik. All rights reserved.
//

import UIKit
import SDWebImage
import CropViewController

/// Encapsulates the Image Picking behavior with cropping support.
class ServiceImagePicker: NSObject {

    enum ImagePickingResult {
        case cancelled
        case selected(image: UIImage, format: ImageFormat)
    }

    enum ImageFormat: String {
        case gif
        case jpeg
        case png

        init(extension ext: String) {
            self = ImageFormat(rawValue: ext) ?? Self.defaultFormat
        }

        enum ImageFormattingError: Error {
            case dataNotCreated
        }

        /// The default image format.
        static let defaultFormat: ImageFormat = .jpeg

        /// Return file extension for this image format.
        public var fileExtension: String { return rawValue }

        public func createData(from image: UIImage) throws -> Data {
            switch self {
            case .gif:
                guard let result = image.sd_imageData(as: .GIF) else { throw ImageFormattingError.dataNotCreated }
                return result
            case .png:
                guard let result = image.pngData() else { throw ImageFormattingError.dataNotCreated }
                return result
            case .jpeg:
                guard let result = image.jpegData(compressionQuality: 1) else { throw ImageFormattingError.dataNotCreated }
                return result
            }
        }
    }

    // MARK: - Properties
    private weak var presenter: PresentingCoordinator?

    // CropViewDelegate handler
    var cropViewControllerDelegateHandler: CropViewControllerDelegate?

    // MARK: Callback
    /// Called when the user finishes picking an image.
    var completion: ((ImagePickingResult) -> Void)?

    // MARK: Private
    /// Image media type
    private static let allowedMediaType = "public.image"

    // MARK: - Initialization
    init(presenter: PresentingCoordinator) {
        self.presenter = presenter
    }

    // MARK: - Private
    func presentError(title: String, message: String, presentingViewController: UIViewController? = nil, dismissPresenter: Bool = true) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Ok", style: .default) { [weak self] _ in
            if dismissPresenter {
                self?.finish(result: .cancelled)
            } else {
                // dismiss alert
                alertController.dismiss(animated: true, completion: nil)
            }
        })

        if let presentingVC = presentingViewController {
            // Present the error with the VC
            presentingVC.present(alertController, animated: true, completion: nil)
        } else {
            // Let a coordinator present it
            presenter?.present(viewController: alertController, animated: true)
        }
    }

    // MARK: - Internal
    func finish(result: ImagePickingResult) {
        completion?(result)
        presenter?.dismissPresentedCoordinator(animated: true, completion: nil)
    }

    // MARK: - Public
    /// Present the `UIImagePickerController` if possible and start the Image Picking flow.
    /// Otherwise an error is presented.
    /// - Parameters:
    ///     - imageFrame: The frame of the image that will be the starting point of the cropViewController presentation animation.
    public func pickImage(imageFrame: CGRect?) {
        guard UIImagePickerController.isSourceTypeAvailable(.photoLibrary) else {
            presentError(
                title: "Photos unavailable",
                message: "There was a problem with accessing your photos. Please verify that you photo library is not empty."
            )
            return
        }

        // Present Picker
        let pickerController = UIImagePickerController()
        pickerController.mediaTypes = [Self.allowedMediaType]
        pickerController.sourceType = .photoLibrary
        pickerController.delegate = self
        presenter?.present(viewController: pickerController, animated: true)
    }
}

// MARK: - UIImagePickerControllerDelegate
extension ServiceImagePicker: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        finish(result: .cancelled)
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        // Verify that the user picked an Image
        guard
            let image = info[.originalImage] as? UIImage,
            let imageURL = info[.imageURL] as? URL
        else {
            finish(result: .cancelled)
            return
        }

        // Check the imageType
        let imageFileExtension = imageURL.pathExtension.lowercased()
        if imageFileExtension == ImageFormat.gif.rawValue, let gifData = try? Data(contentsOf: imageURL), let gifImage = SDAnimatedImage(data: gifData) {
            // GIF
            // Use GIFCropViewController
            presenter?.dismissPresentedCoordinator(animated: true) { [weak self] in
                // Create CropViewController to present
                let cropVC = GIFCropViewController(croppingStyle: .circular, image: gifImage)
                let gifImageCropHandler = GIFImageCropHandler(imageURL: imageURL)
                gifImageCropHandler.imagePicker = self
                self?.cropViewControllerDelegateHandler = gifImageCropHandler
                cropVC.delegate = gifImageCropHandler
                cropVC.set(animatedImage: gifImage)
                self?.presenter?.present(viewController: cropVC, animated: true, modalPresentationStyle: .fullScreen)
            }
        } else {
            presenter?.dismissPresentedCoordinator(animated: true) { [weak self] in
                let cropVC = CustomCropViewController(croppingStyle: .circular, image: image)
                let staticImageCropHandler = StaticImageCropHandler(imageExtension: imageFileExtension)
                staticImageCropHandler.imagePicker = self
                self?.cropViewControllerDelegateHandler = staticImageCropHandler
                cropVC.delegate = staticImageCropHandler
                self?.presenter?.present(viewController: cropVC, animated: true, modalPresentationStyle: .fullScreen)
            }
        }
    }
}
