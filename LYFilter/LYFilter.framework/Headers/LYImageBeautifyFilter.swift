//
//  LYImageBeautifyFilter.swift
//  LineVideo
//
//  Created by tony on 2018/1/16.
//  Copyright © 2018年 chengkaizone. All rights reserved.
//

import UIKit
import GPUImage

public let LYCombinationFragmentShader: String = "varying highp vec2 textureCoordinate; \n varying highp vec2 textureCoordinate2; \n  \n uniform sampler2D inputImageTexture; \n uniform sampler2D inputImageTexture2; \n uniform mediump float smoothDegree; \n  \n void main() \n    { \n    highp vec4 bilateral = texture2D(inputImageTexture, textureCoordinate); \n     highp vec4 origin = texture2D(inputImageTexture2,textureCoordinate2); \n    highp vec4 smooth; \n    lowp float r = origin.r; \n    lowp float g = origin.g; \n    lowp float b = origin.b; \n    if (r > 0.3725 && g > 0.1568 && b > 0.0784 && r > b && (max(max(r, g), b) - min(min(r, g), b)) > 0.0588 && abs(r-g) > 0.0588) { \n    smooth = (1.0 - smoothDegree) * (origin - bilateral) + bilateral; \n    } \n    else { \n    smooth = origin; \n    } \n    smooth.r = log(1.0 + 0.2 * smooth.r)/log(1.2); \n    smooth.g = log(1.0 + 0.2 * smooth.g)/log(1.2); \n    smooth.b = log(1.0 + 0.2 * smooth.b)/log(1.2); \n    gl_FragColor = smooth; \n }  \n "

public let LYCombinationFragmentShader2: String = "varying highp vec2 textureCoordinate; \n varying highp vec2 textureCoordinate2; \n varying highp vec2 textureCoordinate3; \n  \n uniform sampler2D inputImageTexture; \n uniform sampler2D inputImageTexture2; \n uniform sampler2D inputImageTexture3; \n uniform mediump float smoothDegree; \n  \n void main() \n    { \n    highp vec4 bilateral = texture2D(inputImageTexture, textureCoordinate); \n    highp vec4 canny = texture2D(inputImageTexture2, textureCoordinate2); \n    highp vec4 origin = texture2D(inputImageTexture3,textureCoordinate3); \n    highp vec4 smooth; \n    lowp float r = origin.r; \n    lowp float g = origin.g; \n    lowp float b = origin.b; \n    if (canny.r < 0.2 && r > 0.3725 && g > 0.1568 && b > 0.0784 && r > b && (max(max(r, g), b) - min(min(r, g), b)) > 0.0588 && abs(r-g) > 0.0588) { \n    smooth = (1.0 - smoothDegree) * (origin - bilateral) + bilateral; \n    } \n    else { \n    smooth = origin; \n    } \n    smooth.r = log(1.0 + 0.2 * smooth.r)/log(1.2); \n    smooth.g = log(1.0 + 0.2 * smooth.g)/log(1.2); \n    smooth.b = log(1.0 + 0.2 * smooth.b)/log(1.2); \n    gl_FragColor = smooth; \n }  \n "

/** 合并处理 */
public class LYImageCombinationFilter: BasicOperation {
    
    public var intensity: Float = 0.0 {
        didSet {
            self.uniformSettings["smoothDegree"] = intensity
        }
    }
    
    public init() {
        
        super.init(fragmentShader: LYCombinationFragmentShader, numberOfInputs: 2)
    }
    
}

//
public class LYImageBeautifyFilter: OperationGroup {
    
    var bilateralFilter = BilateralBlur()
    //var cannyEdgeFilter = CannyEdgeDetection()
    var combinationFilter = LYImageCombinationFilter()
    
    // 美颜级别 0~10 之间
    public var beautifyLevel: Float = 0.5 {
        didSet {
            
            if beautifyLevel < 0  {// 校准
                combinationFilter.intensity = 0.0
            } else if beautifyLevel > 1.0 {
                combinationFilter.intensity = 1.0
            } else {
                combinationFilter.intensity = beautifyLevel
            }
            
        }
    }
    
    public override init() {
        super.init()
        
        self.bilateralFilter.addTarget(combinationFilter)
        //self.cannyEdgeFilter.addTarget(combinationFilter)
        
        self.combinationFilter.intensity = 0.5
        
        self.configureGroup { (input, output) in
            
            input --> bilateralFilter
            //input --> cannyEdgeFilter
            input --> combinationFilter --> output
        }
        
    }
    
}


