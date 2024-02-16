//
//  ALAssetsLibraryExtension.swift
//  LYCompositionKit
//
//  Created by tony on 16/6/16.
//  Copyright © 2016年 chengkai. All rights reserved.
//

//import Foundation
//import AssetsLibrary

/*
extension ALAssetsLibrary {
    
    /**
     * 通过url获取ALAsset对象的属性
     * 只能作为参考, 不能使用, 因为 ALAsset的所有属性都必须在访问期间获取
     */
    public class func assetForURLRepresentation(_ url: URL) ->LYAssetRepresentation! {
        
        var representation: LYAssetRepresentation!
        let semaphore = DispatchSemaphore(value: 0)
        DispatchQueue(label: "serial queue", attributes: []).async(execute: {
            // 这里不能在主线程中执行
            ALAssetsLibrary().asset(for: url, resultBlock: { (asset: ALAsset?) in
                
                if asset != nil {
                    representation = LYAssetRepresentation(asset: asset!, representation: asset!.defaultRepresentation())
                }
                                // asset在方法块完成之后不能获取任何属性
                semaphore.signal()
                }, failureBlock: { (error: Error?) in
                    
                    DLog("error: \(String(describing: error?.localizedDescription))")
                    semaphore.signal()
            })
        })
        
        let _ = semaphore.wait(timeout: DispatchTime.distantFuture)
        
        return representation
    }
    
    /**
     * 通过url获取ALAsset对象的图片属性
     * 只能作为参考, 不能使用, 因为 ALAsset的所有属性都必须在访问期间获取
     */
    public class func assetForURLImage(_ url: URL) ->UIImage! {
        
        var resultImage: UIImage!
        let semaphore = DispatchSemaphore(value: 0)
        DispatchQueue(label: "serial queue", attributes: []).async(execute: {
            // 这里不能在主线程中执行
            ALAssetsLibrary().asset(for: url, resultBlock: { (asset: ALAsset?) in
                
                if asset != nil {
                    let representation = asset!.defaultRepresentation()
                    resultImage = UIImage(cgImage: (representation?.fullScreenImage().takeUnretainedValue())!)
                    // asset在方法块完成之后不能获取任何属性
                }
                
                semaphore.signal()
                }, failureBlock: { (error: Error?) in
                    
                    DLog("error: \(String(describing: error?.localizedDescription))")
                    semaphore.signal()
            })
        })
        
        let _ = semaphore.wait(timeout: DispatchTime.distantFuture)
        
        return resultImage
    }
    
    /**
     * 获取指定大小的图片
     *
     */
    public class func assetForURLImage(_ url: URL, size: CGSize) ->UIImage {
        
        let image = assetForURLImage(url)
        
        return image!.resizeAspect(size)
    }
    
    /**
     * 检查资源是否存在
     */
    public class func existAssetForURL(_ url: URL) ->Bool {
        
        var flag: Bool = false
        let semaphore = DispatchSemaphore(value: 0)
        DispatchQueue(label: "serial queue", attributes: []).async(execute: {
            // 这里不能在主线程中执行
            ALAssetsLibrary().asset(for: url, resultBlock: { (asset: ALAsset?) in
                
                if asset != nil {
                    flag = true
                }
                semaphore.signal()
                }, failureBlock: { (error: Error?) in
                    
                    DLog("error: \(String(describing: error?.localizedDescription))")
                    semaphore.signal()
            })
        })
        
        let _ = semaphore.wait(timeout: DispatchTime.distantFuture)
        
        return flag
    }
    
}
*/
