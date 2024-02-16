//
//  LYPhotoFilter.swift
//  CameraFilter
//
//  Created by tony on 2017/6/7.
//  Copyright © 2017年 chengkaizone. All rights reserved.
//

import Foundation
import CoreImage

public class LYPhotoFilter: NSObject {
    
    static let FilterSelectedChangedNotification: String = "filter_selection_changed"
    
    public override init() {
        super.init()
    }
    
    class func filterNames() ->[String] {
        let filterNames = ["CIPhotoEffectChrome", "CIPhotoEffectFade", "CIPhotoEffectInstant", "CIPhotoEffectMono",
                           "CIPhotoEffectNoir", "CIPhotoEffectProcess", "CIPhotoEffectTonal", "CIPhotoEffectTransfer"]
        
        return filterNames
    }
    
    public class func defaultFilter() ->CIFilter {
        
        let filter = CIFilter(name: filterNames().first!)
        
        return filter!
    }
    
}
