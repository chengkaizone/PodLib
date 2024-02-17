//
//  LYImageFilter.swift
//  LineVideo
//
//  Created by tony on 2018/1/14.
//  Copyright © 2018年 chengkaizone. All rights reserved.
//

import UIKit
import GPUImage

public class LYImageFilter: OperationGroup {
    
    public override init() {
        super.init()

    }
    
    public init(fragmentShader: String, inputs: [PictureInput]? = nil) {
        super.init()
        
        var filter: BasicOperation!
        if let inputs = inputs {
            filter = BasicOperation(fragmentShader: fragmentShader, numberOfInputs: UInt(inputs.count + 1))

            var sourceIndex: UInt = 1
            for source: PictureInput in inputs {
    
                source.addTarget(filter, atTargetIndex: sourceIndex)
                source.processImage()
                sourceIndex = sourceIndex + 1
            }
        } else {
            filter = BasicOperation(fragmentShader: fragmentShader, numberOfInputs: 1)
        }
        
        self.configureGroup { (input, output) in
            
            input --> filter --> output
        }
    }
    
    /**
     * 加载bundle中的滤镜处理图片
     **/
    public class func pictureInput(name: String) ->PictureInput {
        guard let bundlePath = Bundle(for: TestBundle().classForCoder).path(forResource: "CustomResource", ofType: "bundle"), let filterImageBundle = Bundle(path: bundlePath), let path = filterImageBundle.path(forResource: name, ofType: "png"), let image = UIImage(contentsOfFile: path) else {
            return PictureInput(imageName: "")
        }
        
        return PictureInput(image: image)
    }
}

