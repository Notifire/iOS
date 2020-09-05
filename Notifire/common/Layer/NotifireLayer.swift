//
//  NotifireLayer.swift
//  Notifire
//
//  Created by David Bielik on 01/09/2018.
//  Copyright © 2018 David Bielik. All rights reserved.
//

import UIKit

class NotifireLayer: BaseLayer {

    // MARK: - Properties
    private var replicatedLayers = [CAShapeLayer]()

    var fireLayersSettings: [FireLayerProperties] = [] {
        didSet {
            updateInstances()
        }
    }

    var firePaths = [CGPath]()

    let multiplePathAnimator = MultiplePathAnimator()

    // MARK: - Inherited
    override func layoutSublayers() {
        super.layoutSublayers()

        // setup fire paths
        let firstFirePath = UIBezierPath(roundedRect: bounds, cornerRadius: 60)
        let secondFirePath = UIBezierPath(roundedRect: bounds, cornerRadius: 10)
        let thirdFirePath = UIBezierPath(roundedRect: bounds.insetBy(dx: 40, dy: 40), cornerRadius: 4)
        firePaths = [firstFirePath.cgPath, secondFirePath.cgPath, thirdFirePath.cgPath]

        // update sublayer bounds
        replicatedLayers.forEach {
            $0.bounds = bounds
            $0.position = CGPoint(x: bounds.midX, y: bounds.midY)
        }
    }

    // MARK: - Private
    private func updateInstances() {
        if sublayers != nil {
            replicatedLayers.forEach { $0.removeFromSuperlayer() }
            replicatedLayers.removeAll(keepingCapacity: false)
        }
        for options in fireLayersSettings {
            let layer = CAPersistentAnimationsShapeLayer()
            layer.bounds = bounds
            layer.position = CGPoint(x: bounds.midX, y: bounds.midY)
            layer.path = firePaths.first
            layer.fillColor = options.fillColor.cgColor
            layer.opacity = options.opacity
            let scaleTransform = CATransform3DMakeScale(options.relativeScaleFactor.x, options.relativeScaleFactor.y, 1)
            layer.transform = CATransform3DTranslate(scaleTransform, 0, options.translationY, 0)

            replicatedLayers.append(layer)
            addSublayer(layer)
        }
    }

    // MARK: - Public
    public func startFireAnimation() {
        multiplePathAnimator.animate(layers: replicatedLayers, paths: firePaths)
    }

    public func stopFireAnimation() {
        multiplePathAnimator.stopAnimating(layers: replicatedLayers)
    }
}
