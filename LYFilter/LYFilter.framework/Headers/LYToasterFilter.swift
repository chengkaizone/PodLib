//
//  LYToasterFilter.swift
//  LineVideo
//
//  Created by tony on 2018/1/14.
//  Copyright © 2018年 chengkaizone. All rights reserved.
//

/// 烛光 candlelight
public class LYToasterFilter: LYImageFilter {

    public override init() {
        
        super.init(fragmentShader: LYToasterFragmentShader, inputs: [LYImageFilter.pictureInput(name: "candlelightMetal"), LYImageFilter.pictureInput(name: "candlelightSoftLight"), LYImageFilter.pictureInput(name: "candlelightCurves"), LYImageFilter.pictureInput(name: "candlelightOverlayMapWarm"), LYImageFilter.pictureInput(name: "candlelightColorShift")])
    }
    
}
