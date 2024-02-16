//
//  LYLomofiFilter.swift
//  LineVideo
//
//  Created by tony on 2018/1/14.
//  Copyright © 2018年 chengkaizone. All rights reserved.
//

/// LOMO lomo
public class LYLomofiFilter: LYImageFilter {
    
    public override init() {
        
        super.init(fragmentShader: LYLomofiFragmentShader, inputs: [LYImageFilter.pictureInput(name: "lomoMap"), LYImageFilter.pictureInput(name: "vignetteMap")])
    }
    
}
