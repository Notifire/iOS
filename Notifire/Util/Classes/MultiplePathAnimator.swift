//
//  MultiplePathAnimator.swift
//  Notifire
//
//  Created by David Bielik on 01/09/2018.
//  Copyright © 2018 David Bielik. All rights reserved.
//

import UIKit

class MultiplePathAnimator: NSObject {

    // MARK: - Properties
    // MARK: Static
    static let pathKey = "path"
    static let layerKey = "animatedLayer"

    // MARK: Animation
    var runningAnimations = [CAAnimation]()
    var pathIterator: IndexingIterator<[CGPath]>?
    var pathsIterators: [CAShapeLayer: IndexingIterator<[CGPath]>] = [:]

    func addAnimation(to layer: CAShapeLayer) {
        func getNextPath() -> CGPath? {
            if let result = pathsIterators[layer]?.next() {
                return result
            } else {
                pathsIterators[layer] = pathIterator
                return pathsIterators[layer]?.next()
            }
        }
        let toPath = getNextPath()
        let pathAnim = CABasicAnimation(keyPath: MultiplePathAnimator.pathKey)
        pathAnim.fillMode = CAMediaTimingFillMode.forwards
        pathAnim.fromValue = layer.path
        pathAnim.toValue = toPath
        pathAnim.duration = 0.6
        pathAnim.isAdditive = true
        pathAnim.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.linear)
        pathAnim.delegate = self
        pathAnim.setValue(layer, forKey: MultiplePathAnimator.layerKey)
        layer.add(pathAnim, forKey: MultiplePathAnimator.pathKey)
        layer.path = toPath
    }

    func animate(layers: [CAShapeLayer], paths: [CGPath]) {
        runningAnimations = []
        pathIterator = paths.makeIterator()
        for layer in layers {
            pathsIterators[layer] = paths.makeIterator()
            addAnimation(to: layer)
        }
    }

    func stopAnimating(layers: [CAShapeLayer]) {
        layers.forEach { $0.removeAnimation(forKey: MultiplePathAnimator.pathKey )}
    }
}

// MARK: - CAAnimationDelegate
extension MultiplePathAnimator: CAAnimationDelegate {
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        guard flag, let layer = anim.value(forKey: MultiplePathAnimator.layerKey) as? CAShapeLayer else { return }
        addAnimation(to: layer)
    }
}
