//
//  LY1977Filter.swift
//  LineVideo
//
//  Created by tony on 2018/1/14.
//  Copyright © 2018年 chengkaizone. All rights reserved.
//
import UIKit
/// 粉嫩 pink
public class LY1977Filter: LYImageFilter {
    
    public override init() {
        super.init(fragmentShader: LY1977FragmentShader, inputs: [LYImageFilter.pictureInput(name: "pinkMap") /*, LYImageFilter.pictureInput(name: "pinkBlowout") */])
    }
}

