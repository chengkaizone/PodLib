//
//  LYRiseFilter.swift
//  LineVideo
//
//  Created by tony on 2018/1/14.
//  Copyright © 2018年 chengkaizone. All rights reserved.
//

/// 唯美 beautiful
public class LYRiseFilter: LYImageFilter {

    public override init() {
        
        super.init(fragmentShader: LYRiseFragmentShader, inputs: [LYImageFilter.pictureInput(name: "blackboardLarge"), LYImageFilter.pictureInput(name: "overlayMap"), LYImageFilter.pictureInput(name: "beautifulMap")])
    }
    
}
