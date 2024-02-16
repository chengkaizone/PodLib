//
//  LYHudsonFilter.swift
//  LineVideo
//
//  Created by tony on 2018/1/14.
//  Copyright © 2018年 chengkaizone. All rights reserved.
//

/// 流年 fleeting
public class LYHudsonFilter: LYImageFilter {

    public override init() {
        
        super.init(fragmentShader: LYHudsonFragmentShader, inputs: [LYImageFilter.pictureInput(name: "childhoodBackground"), LYImageFilter.pictureInput(name: "overlayMap"), LYImageFilter.pictureInput(name: "childhoodMap")])
    }
    
}
