//
//  BaseViewController.swift
//  LineCal
//
//  Created by tony on 2017/4/1.
//  Copyright © 2017年 chengkaizone. All rights reserved.
//

import UIKit

open class BaseViewController: UIViewController {
    
    public var logLifcycleEnabled:Bool = false //是否启用生命日志
    /// 0:push(default) 1:present 2:attach
    public var pushType: Int = 0
    /// 是否启用手势返回
    
    public var statusBarShouldLight: Bool = true {
        didSet {
            if statusBarShouldLight == oldValue {
                return
            }
            setNeedsStatusBarAppearanceUpdate()
        }
    }
    public var statusBarShouldHidden: Bool = false
    
    func switchTheme(now: Any, pre: Any?) {
        // 不要赋值主题
    }
    
    open func primaryColor() ->UIColor {
        return UICommonSdk.getPrimaryColor()
    }
    
    open func accentColor() ->UIColor {
        return UICommonSdk.getAccentColor()
    }
    
    open func extraColor() ->UIColor {
        return UICommonSdk.getExtraColor()
    }
    
    /// 是否启用键盘输入管理
    /// - Returns:
    open func splashEnabled() -> Bool {
        return true
    }
    
    open func flashbackEnabled() -> Bool {
        return true
    }
    
    /// 是否启用键盘输入管理
    /// - Returns:
    open func keyboardInputEnabled() -> Bool {
        return false
    }
    
    open override var preferredStatusBarStyle: UIStatusBarStyle {
        if statusBarShouldLight {
            return .lightContent
        }
        return .lightContent
    }
    
    open override var prefersStatusBarHidden: Bool {
        return statusBarShouldHidden
    }
    
    open override var shouldAutorotate: Bool {
        return false
    }
    
    open override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    
    open override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
        return .portrait
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        if(self.logLifcycleEnabled){
            NSLog("%@ viewDidLoad",NSStringFromClass(self.classForCoder))
        }
        
        self.navigationController?.navigationBar.isTranslucent = false
        self.view.backgroundColor = UICommonSdk.getViewBackgroundColor()
        
        let screenBounds = UIScreen.main.bounds
        NSLog("desity : \(UIScreen.main.scale)  screen : \(NSCoder.string(for: screenBounds)) sysVersion : \(sysVersion())  \(UIScreen.main.nativeScale)   \(UIScreen.main.nativeBounds)")
        
        if !splashEnabled() {
            UICommonSdk.stopSplash()
        }
        UICommonSdk.setFlashbackAction(isFlashbackEnabled: flashbackEnabled())
    }
    
    /** 得到系统版本 */
    func sysVersion() -> Float {
        let sysVersion:String = UIDevice.current.systemVersion;
        let versionCode:Float = (sysVersion as NSString).floatValue;
        return versionCode;
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
        self.cleanMemory()
        if(self.logLifcycleEnabled){
            NSLog("%@ deinit",NSStringFromClass(self.classForCoder))
        }
        if !splashEnabled() {
            UICommonSdk.resumeSplash()
        }
    }
    
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UICommonSdk.setKeyboardManagerAction(keyboardInputEnabled: keyboardInputEnabled())
        UICommonSdk.setAnalysisBeginPageView(clazzName: NSStringFromClass(self.classForCoder))
        if(self.logLifcycleEnabled){
            NSLog("%@ viewWillAppear",NSStringFromClass(self.classForCoder));
        }
    }
    
    open override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        UICommonSdk.setFlashbackAction(isFlashbackEnabled: flashbackEnabled())
        
        if(self.logLifcycleEnabled){
            NSLog("%@ viewDidAppear",NSStringFromClass(self.classForCoder));
        }
    }
    
    open override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        UICommonSdk.setKeyboardManagerAction(keyboardInputEnabled: false)
        UICommonSdk.setAnalysisEndPageView(clazzName: NSStringFromClass(self.classForCoder))
        
        if(self.logLifcycleEnabled){
            NSLog("%@ viewWillDisappear",NSStringFromClass(self.classForCoder));
        }
    }
    
    open override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated);
        if(self.logLifcycleEnabled){
            NSLog("%@ viewDidDisappear",NSStringFromClass(self.classForCoder));
        }
    }
    
    open override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews();
        if(self.logLifcycleEnabled){
            //NSLog("%@ viewWillLayoutSubviews",NSStringFromClass(self.classForCoder));
        }
    }
    
    open override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        if(self.logLifcycleEnabled){
            NSLog("%@ didReceiveMemoryWarning",NSStringFromClass(self.classForCoder));
        }
    }
    
    func cleanMemory() {
        if(self.logLifcycleEnabled){
            NSLog("%@ cleanMemory",NSStringFromClass(self.classForCoder));
        }
    }
    
}

extension BaseViewController: UIGestureRecognizerDelegate {
    
    public func gestureRecognizerShouldBegin(_ gestureRecognizer:UIGestureRecognizer) -> Bool {
        if (self.children.count == 1) {
            return false
        }
        return true
    }
    
}

