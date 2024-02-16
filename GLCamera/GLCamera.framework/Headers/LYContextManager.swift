//
//  LYContextManager.swift
//  CameraFilter
//
//  Created by tony on 2017/6/7.
//  Copyright © 2017年 chengkaizone. All rights reserved.
//

import UIKit

public class LYContextManager: NSObject {
    
    open var eaglContext: EAGLContext!
    open var ciContext: CIContext!
    
    public override init() {
        super.init()
        self.eaglContext = EAGLContext(api: EAGLRenderingAPI.openGLES3)
        let options = [CIContextOption.workingColorSpace: NSNull()]
        self.ciContext = CIContext(eaglContext: eaglContext, options: options)
    }
    
    open class func shared() ->LYContextManager {
        struct Static {
            static let instance = LYContextManager()
            
        }
        return Static.instance
    }
    
}
