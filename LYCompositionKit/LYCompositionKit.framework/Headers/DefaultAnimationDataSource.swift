//
//  DefaultAnimationDataSource.swift
//  LYCompositionKit
//
//  Created by tony on 2017/8/26.
//  Copyright © 2017年 chengkai. All rights reserved.
//

import UIKit

open class DefaultAnimationDataSource {
    
    // MARK: - Variables
    
    let animationCalculator: LYImageAnimationCalculatorProtocol
    
    // MARK: - Init
    
    init(animationCalculator: LYImageAnimationCalculatorProtocol) {
        self.animationCalculator = animationCalculator
    }
    
    //convenience init(animationDependencies: LYImageAnimationDependencies) {
        //self.init(animationCalculator: ImageAnimationCalculator(animationDependencies: animationDependencies))
    //}
    
    // MARK: - Public
    func buildImageAnimation(image: UIImage, forViewPortSize viewPortSize: CGSize) -> LYImageAnimation {
        let imageSize = image.size
        
        let startScale = animationCalculator.buildRandomScale(imageSize: imageSize, viewPortSize: viewPortSize)
        let endScale = animationCalculator.buildRandomScale(imageSize: imageSize, viewPortSize: viewPortSize)
        
        let scaledStartImageSize = imageSize.scaledSize(scale: startScale)
        let scaledEndImageSize = imageSize.scaledSize(scale: endScale)
        
        let imageStartPosition = animationCalculator.buildPinnedToEdgesPosition(imageSize: scaledStartImageSize,
                                                                                viewPortSize: viewPortSize)
        let imageEndPosition = animationCalculator.buildOppositeAnglePosition(startPosition: imageStartPosition,
                                                                              imageSize: scaledEndImageSize,
                                                                              viewPortSize: viewPortSize)
        
        let duration = animationCalculator.buildAnimationDuration()
        
        let imageStartState = LYImageState(scale: startScale, position: imageStartPosition)
        let imageEndState = LYImageState(scale: endScale, position: imageEndPosition)
        let imageTransition = LYImageAnimation(startState: imageStartState, endState: imageEndState, duration: duration)
        
        return imageTransition
    }
    
    // MARK: - Private
    
    private func translateToImageCoordinates(point: CGPoint, imageSize: CGSize, viewPortSize: CGSize) -> CGPoint {
        
        let x = imageSize.width / 2 - viewPortSize.width / 2 - point.x
        let y = imageSize.height / 2 - viewPortSize.height / 2 - point.y
        
        let position = CGPoint(x: x, y: y)
        return position
    }
}
