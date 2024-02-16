//
//  LYCompositionLayer.swift
//  LYCompositionKit
//
//  Created by tony on 16/3/4.
//  Copyright © 2016年 chengkai. All rights reserved.
//

import UIKit
import QuartzCore

/** 参与视频合成的图层 */
open class LYCompositionLayer: LYTimelineItem {
    
    var identifier:String?;
    
    open func layer() ->CALayer! {
        
        DLog("Must be overridden by subclass.");
        return nil;
    }
    
}
