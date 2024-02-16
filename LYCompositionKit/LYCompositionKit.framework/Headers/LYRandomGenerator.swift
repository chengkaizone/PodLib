//
//  LYRandomGenerator.swift
//  LYCompositionKit
//
//  Created by tony on 2017/8/26.
//  Copyright © 2017年 chengkai. All rights reserved.
//

import Foundation

public protocol LYRandomGeneratorProtocol {
    
    func randomBool() -> Bool
    func randomCGFloat(min: CGFloat, max: CGFloat) -> CGFloat
    func randomFloat(min: Float, max: Float) -> Float
    func randomDouble(min: Double, max: Double) -> Double
    func randomInt(min: Int, max: Int) -> Int
}


open class LYRandomGenerator: LYRandomGeneratorProtocol {
    
    // MARK: - Public
    
    open func randomBool() -> Bool {
        return Bool.random()
    }
    
    open func randomCGFloat(min: CGFloat = 0.0, max: CGFloat) -> CGFloat {
        return CGFloat.random(min: min, max: max)
    }
    
    open func randomFloat(min: Float = 0.0, max: Float) -> Float {
        return Float.random(min: min, max: max)
    }
    
    open func randomDouble(min: Double = 0.0, max: Double) -> Double {
        return Double.random(min: min, max: max)
    }
    
    open func randomInt(min: Int  = 0, max: Int) -> Int {
        return Int.random(min: min, max: max)
    }
    
}
