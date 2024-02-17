//
//  WebViewController.swift
//  LineCal
//
//  Created by tony on 2022/11/9.
//  Copyright © 2022 chengkaizone. All rights reserved.
//

import UIKit
import WebKit
import SnapKit

/**
 通用网页加载页面
 */
public class WebViewController: BaseViewController {
    
    // 网页标题
    public var titleText: String!
    public var urlRequest: URLRequest!
    lazy var mWebview: WKWebView = {
        let wkWebConfig = WKWebViewConfiguration()
        // 自适应屏幕宽度js
        let jSString = "var meta = document.createElement('meta'); meta.setAttribute('name', 'viewport'); meta.setAttribute('content', 'width=device-width'); document.getElementsByTagName('head')[0].appendChild(meta);"
        let wkUserScript = WKUserScript(source: jSString, injectionTime: WKUserScriptInjectionTime.atDocumentEnd, forMainFrameOnly: true)
        // 添加自适应屏幕宽度js调用的方法
        wkWebConfig.userContentController.addUserScript(wkUserScript)
        let webview = WKWebView(frame: CGRect.zero, configuration: wkWebConfig)
        webview.backgroundColor = UICommonSdk.getViewBackgroundColor()
        webview.addObserver(self, forKeyPath: "estimatedProgress", options: [.new, .old], context: nil)
        return webview
    }()
    
    lazy var progressView: UIProgressView = {
       
        let progressView = UIProgressView(frame: CGRect.zero)
        progressView.progressViewStyle = .bar
        progressView.backgroundColor = UIColor.white
        progressView.trackTintColor = UIColor.white
        progressView.progressTintColor = UICommonSdk.getPrimaryColor()
        return progressView
    }()
    
    lazy var btGoBack: UIButton = {
        
        let button = UIButton(type: .custom)
        button.setImage(UICommonSdk.getWebGobackImage(), for: .normal)
        button.setImage(UICommonSdk.getWebGobackImageSelected(), for: .selected)
        button.setImage(UICommonSdk.getWebGobackImageSelected(), for: .highlighted)
        button.addTarget(self, action: #selector(goBackAction(sender:)), for: .touchUpInside)
        return button
    }()
    
    lazy var btGoForward: UIButton = {
        
        let button = UIButton(type: .custom)
        button.setImage(UICommonSdk.getWebGoforwardImage(), for: .normal)
        button.setImage(UICommonSdk.getWebGoforwardImageSelected(), for: .selected)
        button.setImage(UICommonSdk.getWebGoforwardImageSelected(), for: .highlighted)
        button.addTarget(self, action: #selector(goForwardAction(sender:)), for: .touchUpInside)
        return button
    }()
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.initWithViewController(self, title: titleText, primaryColor: UICommonSdk.getPrimaryColor())
        self.navigationController?.navigationBar.leftBarAction(self, image: UICommonSdk.getNavBackIcon(), action: #selector(leftAction(_:)))
        self.navigationController?.navigationBar.rightBarAction(self, image: UICommonSdk.getNavCancelIcon(), action: #selector(dismissAction(_:)))
        
        setup()
        loadUrl()
    }
    
    /// 加载网页
    public static func load(title: String, url: String) ->WebViewController {
        let control = WebViewController()
        control.titleText = title
        let request = NSMutableURLRequest(url: URL(string: url)!)
        control.urlRequest = request as URLRequest
        return control
    }
    
    /// 加载网页请求
    public static func load(title: String, urlRequest: URLRequest) ->WebViewController {
        let control = WebViewController()
        control.titleText = title
        control.urlRequest = urlRequest
        return control
    }
    
    deinit {
        mWebview.removeObserver(self, forKeyPath: "estimatedProgress")
    }
    
    @objc func leftAction(_ sender: UIButton) {
        if (mWebview.canGoBack) {
            mWebview.goBack()
        } else {
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    @objc func dismissAction(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    fileprivate func setup() {
        self.view.addSubview(mWebview)
        mWebview.snp.makeConstraints { make in
            make.left.right.top.bottom.equalToSuperview()
        }
        self.view.addSubview(progressView)
        progressView.snp.makeConstraints { make in
            make.left.right.top.equalToSuperview()
            make.height.equalTo(1)
        }
        
        self.view.addSubview(btGoBack)
        btGoBack.snp.makeConstraints { make in
            make.width.height.equalTo(36)
            make.centerX.equalToSuperview().offset(-32)
            make.bottom.equalTo(self.view.safeAreaLayoutGuide.snp.bottom).offset(-54)
        }
        
        self.view.addSubview(btGoForward)
        btGoForward.snp.makeConstraints { make in
            make.width.height.equalTo(36)
            make.centerX.equalToSuperview().offset(32)
            make.bottom.equalTo(self.view.safeAreaLayoutGuide.snp.bottom).offset(-54)
        }
        btGoBack.isEnabled = false
        btGoForward.isEnabled = false
    }
    
    @objc func goBackAction(sender: UIButton) {
        if (mWebview.canGoBack) {
            mWebview.goBack()
        }
    }
    
    @objc func goForwardAction(sender: UIButton) {
        if mWebview.canGoForward {
            mWebview.goForward()
        }
    }
    
    fileprivate func loadUrl() {
        mWebview.load(urlRequest)
    }
    
    public override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        
        if keyPath == "estimatedProgress" {
            progressView.progress = Float(mWebview.estimatedProgress)
            if mWebview.estimatedProgress >= 1.0 {
                checkState()
                UIView.animate(withDuration: 0.3) {[weak self] in
                    self?.progressView.alpha = 0.0
                }
            } else {
                progressView.alpha = 1.0
            }
        }
    }

    func checkState() {
        if mWebview.canGoBack {
            btGoBack.isSelected = false
            btGoBack.isEnabled = true
        } else {
            btGoBack.isSelected = true
            btGoBack.isEnabled = false
        }
        
        if mWebview.canGoForward {
            btGoForward.isSelected = false
            btGoForward.isEnabled = true
        } else {
            btGoForward.isSelected = true
            btGoForward.isEnabled = false
        }
    }
    
}

