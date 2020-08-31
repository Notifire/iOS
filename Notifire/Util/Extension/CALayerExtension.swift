//
//  CALayerExtension.swift
//  Notifire
//
//  Created by David Bielik on 31/08/2018.
//  Copyright © 2018 David Bielik. All rights reserved.
//

import UIKit

// MARK: - PersistentAnimationsObserving
extension CALayer {
    func pause() {
        if self.isPaused == false {
            let pausedTime: CFTimeInterval = self.convertTime(CACurrentMediaTime(), from: nil)
            self.speed = 0.0
            self.timeOffset = pausedTime
        }
    }
    
    var isPaused: Bool {
        return self.speed == 0.0
    }
    
    func resume() {
        let pausedTime: CFTimeInterval = self.timeOffset
        self.speed = 1.0
        self.timeOffset = 0.0
        self.beginTime = 0.0
        let timeSincePause: CFTimeInterval = self.convertTime(CACurrentMediaTime(), from: nil) - pausedTime
        self.beginTime = timeSincePause
    }
}

// MARK: - Speed
extension CALayer {
    func changeSpeed(to newSpeed: Float) {
//        speed = newSpeed
//        let mediaTime = CACurrentMediaTime()
//        let convertedTime = convertTime(mediaTime, to: nil)
//        beginTime = mediaTime
//        let offset = mediaTime - ((convertedTime - beginTime) * Double(newSpeed))
//        timeOffset = offset
        timeOffset = convertTime(CACurrentMediaTime(), from: nil)
        beginTime = CACurrentMediaTime()
        speed = newSpeed
    }
    
    func multiplySpeed(by: Float) {
        let newSpeed = speed * by
        changeSpeed(to: newSpeed)
    }
}
