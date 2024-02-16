//
//  LYEarlybirdFilter.swift
//  LineVideo
//
//  Created by tony on 2018/1/14.
//  Copyright © 2018年 chengkaizone. All rights reserved.
//

/// 柔光 softlight
public class LYEarlybirdFilter: LYImageFilter {
    
    public override init() {
        
        super.init(fragmentShader: LYEarlybirdFragmentShader, inputs: [LYImageFilter.pictureInput(name: "softlightCurves"), LYImageFilter.pictureInput(name: "softlightOverlayMap"), LYImageFilter.pictureInput(name: "vignetteMap"), LYImageFilter.pictureInput(name: "softlightBlowout"), LYImageFilter.pictureInput(name: "softlightMap")])
    }
}

