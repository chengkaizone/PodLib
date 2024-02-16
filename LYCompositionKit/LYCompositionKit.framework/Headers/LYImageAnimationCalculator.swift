//
//  LYImageAnimationCalculator.swift
//  LYCompositionKit
//
//  Created by tony on 2017/8/26.
//  Copyright © 2017年 chengkai. All rights reserved.
//

import Foundation

public protocol LYImageAnimationCalculatorProtocol {
    
    func buildPinnedToEdgesPosition(imageSize: CGSize, viewPortSize: CGSize) -> CGPoint
    
    func buildOppositeAnglePosition(startPosition: CGPoint, imageSize: CGSize, viewPortSize: CGSize) -> CGPoint
    
    func buildFacePosition(faceRect: CGRect, imageSize: CGSize, viewPortSize: CGSize) -> CGPoint
    
    func buildAnimationDuration() -> Double
    
    func buildRandomScale(imageSize: CGSize, viewPortSize: CGSize) -> CGFloat
    
}

open class ImageAnimationCalculator: LYImageAnimationCalculatorProtocol {
    
    // MARK: - Variables
    
    private let randomGenerator: LYRandomGeneratorProtocol
    private let animationDependencies: LYImageAnimationDependencies
    
    // MARK: - Init
    public init(randomGenerator: LYRandomGeneratorProtocol?, animationDependencies: LYImageAnimationDependencies) {
        
        if randomGenerator == nil {
            self.randomGenerator = LYRandomGenerator()
        } else {
            self.randomGenerator = randomGenerator!
        }
        self.animationDependencies = animationDependencies
    }
    
    // MARK: - Public
    
    open func buildPinnedToEdgesPosition(imageSize: CGSize, viewPortSize: CGSize) -> CGPoint {
        let imageXDeviation = imageSize.width / 2 - viewPortSize.width / 2
        let imageYDeviation = imageSize.height / 2 - viewPortSize.height / 2
        
        let isXPinned = randomGenerator.randomBool()
        
        var imagePositionX: CGFloat = 0.0
        var imagePositionY: CGFloat = 0.0
        if isXPinned {
            imagePositionX = randomGenerator.randomBool() ? -imageXDeviation : imageXDeviation
            imagePositionY = randomGenerator.randomCGFloat(min: -imageYDeviation, max: imageYDeviation)
        } else {
            imagePositionX = randomGenerator.randomCGFloat(min: -imageXDeviation, max: imageXDeviation)
            imagePositionY = randomGenerator.randomBool() ? -imageYDeviation : imageYDeviation
        }
        
        let imagePosition = CGPoint(x: imagePositionX, y: imagePositionY)
        return imagePosition
    }
    
    open func buildOppositeAnglePosition(startPosition: CGPoint, imageSize: CGSize, viewPortSize: CGSize) -> CGPoint {
        let imageXDeviation = imageSize.width / 2 - viewPortSize.width / 2
        let imageYDeviation = imageSize.height / 2 - viewPortSize.height / 2
        
        var imagePositionX: CGFloat = 0.0
        if startPosition.x < 0 {
            imagePositionX = randomGenerator.randomCGFloat(min: 0.0, max: imageXDeviation)
        } else {
            imagePositionX = randomGenerator.randomCGFloat(min: -imageXDeviation, max: 0.0)
        }
        
        var imagePositionY: CGFloat = 0.0
        if startPosition.y < 0 {
            imagePositionY = randomGenerator.randomCGFloat(min: 0.0, max: imageYDeviation)
        } else {
            imagePositionY = randomGenerator.randomCGFloat(min: -imageYDeviation, max: 0.0)
        }
        
        let imageEndPosition = CGPoint(x: imagePositionX, y: imagePositionY)
        
        return imageEndPosition
    }
    
    /// 创建面部位置
    open func buildFacePosition(faceRect: CGRect, imageSize: CGSize, viewPortSize: CGSize) -> CGPoint {
        let imageCenter = CGPoint(x: viewPortSize.width / 2, y: viewPortSize.height / 2)
        let imageFrame = CGRect(center: imageCenter, size: imageSize)
        
        let centerOfFaceRect = faceRect.center()
        
        let topCompensation = centerOfFaceRect.y - viewPortSize.height / 2
        let bottomCompensation = imageFrame.size.height - (centerOfFaceRect.y + viewPortSize.height / 2)
        var yCompensation: CGFloat = 0.0
        if topCompensation < 0.0 {
            yCompensation = -topCompensation
        } else if bottomCompensation < 0.0 {
            yCompensation = bottomCompensation
        }
        
        let leftCompensation = centerOfFaceRect.x - viewPortSize.width / 2
        let rightCompensation = imageFrame.size.width - (centerOfFaceRect.x + viewPortSize.width / 2)
        var xCompensation: CGFloat = 0.0
        if leftCompensation < 0.0 {
            xCompensation = -leftCompensation
        } else if rightCompensation < 0.0 {
            xCompensation = rightCompensation
        }
        
        let positionX = -(centerOfFaceRect.x - viewPortSize.width / 2 + imageFrame.origin.x + xCompensation)
        let positionY = -(centerOfFaceRect.y - viewPortSize.height / 2 + imageFrame.origin.y + yCompensation)
        let position = CGPoint(x: positionX, y: positionY)
        return position
    }
    
    // 创建随机动画时间
    open func buildAnimationDuration() -> Double {
        let animationDuration = animationDependencies.animationDuration
        let animationDurationDeviation = animationDependencies.animationDurationDeviation
        
        var durationDeviation = 0.0
        if animationDurationDeviation > 0.0 {
            durationDeviation = randomGenerator.randomDouble(min: -animationDurationDeviation,
                                                             max: animationDurationDeviation)
        }
        let duration = animationDuration + durationDeviation
        return duration
    }
    
    // 创建随机缩放值
    open func buildRandomScale(imageSize: CGSize, viewPortSize: CGSize) -> CGFloat {
        let scaleFactorDeviation = animationDependencies.scaleFactorDeviation
        let scaleForAspectFill = imageScaleForAspectFill(imageSize: imageSize, viewPortSize: viewPortSize)
        let scaleDeviation = randomGenerator.randomCGFloat(min: 0.0, max: CGFloat(scaleFactorDeviation))
        let scale = scaleForAspectFill + scaleDeviation
        return scale
    }
    
    // MARK: - Private
    // 图片完全缩放至占满窗口的比例值, centerCrop
    private func imageScaleForAspectFill(imageSize: CGSize, viewPortSize: CGSize) -> CGFloat {
        let widthScale = viewPortSize.width / imageSize.width
        let heightScale = viewPortSize.height / imageSize.height
        let scaleForAspectFill = max(heightScale, widthScale)
        return scaleForAspectFill
    }
}
