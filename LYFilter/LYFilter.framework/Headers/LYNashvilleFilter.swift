//
//  LYNashvilleFilter.swift
//  LineVideo
//
//  Created by tony on 2018/1/14.
//  Copyright © 2018年 chengkaizone. All rights reserved.
//

/// 粉黛 powder
public class LYNashvilleFilter: LYImageFilter {

    public override init() {
        
        super.init(fragmentShader: LYNashvilleFragmentShader, inputs: [LYImageFilter.pictureInput(name: "powderMap")])
    }
    
}
