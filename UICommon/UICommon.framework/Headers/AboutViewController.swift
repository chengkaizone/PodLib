//
//  AboutViewController.swift
//  LineCal
//
//  Created by tony on 2017/4/1.
//  Copyright © 2017年 chengkaizone. All rights reserved.
//

import UIKit
import SnapKit

/// 关于页面
public class AboutViewController: BaseViewController {

    lazy var logoImageView: UIImageView = {
        let imageView = UIImageView(frame: CGRect.zero)
        
        return imageView
    }()
    lazy var labelApp: UILabel = {
        let label = UILabel(frame: CGRect.zero)
        label.textColor = UIColor(argb: "#FF505050")
        label.font = UIFont.systemFont(ofSize: 15)
        label.textAlignment = NSTextAlignment.center
        
        return label
    }()

    lazy var labelTerms: UILabel = {
        let label = UILabel(frame: CGRect.zero)
        label.textColor = UIColor(argb: "#FF009FF7")
        label.font = UIFont.systemFont(ofSize: 12)
        label.textAlignment = NSTextAlignment.center
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapTerms(_:)))
        label.addGestureRecognizer(tapGesture)
        label.isUserInteractionEnabled = true
        label.text = "《\(UICommonSdk.getUserTermsTitle())》"
        label.sizeToFit()
        
        return label
    }()
    lazy var labelPrivacy: UILabel = {
        let label = UILabel(frame: CGRect.zero)
        label.textColor = UIColor(argb: "#FF009FF7")
        label.font = UIFont.systemFont(ofSize: 12)
        label.textAlignment = NSTextAlignment.center
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapPrivacy(_:)))
        label.addGestureRecognizer(tapGesture)
        label.isUserInteractionEnabled = true
        label.text = "《\(UICommonSdk.getPrivacyTitle())》"
        label.sizeToFit()
        
        return label
    }()
    
    lazy var labelICP: UILabel = {
        let label = UILabel(frame: CGRect.zero)
        label.textColor = UIColor(argb: "#C0C0C0")
        label.font = UIFont.systemFont(ofSize: 10)
        label.textAlignment = NSTextAlignment.center
        label.text = UICommonSdk.getIcp()
        label.sizeToFit()
        return label
    }()
    
    lazy var labelTip: UILabel = {
        let label = UILabel(frame: CGRect.zero)
        label.textColor = UIColor(white: 0, alpha: 0.15)
        label.font = UIFont.systemFont(ofSize: 10)
        label.textAlignment = .right
        label.sizeToFit()
        return label
    }()
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.initWithViewController(self, title: UICommonSdk.getAboutTitle(), primaryColor: UICommonSdk.getPrimaryColor())
        self.navigationController?.navigationBar.leftBarAction(self, image: UICommonSdk.getNavBackIcon(), action: #selector(leftAction(_:)))
        
        setup()
    }
    
    fileprivate func setup() {
        
        self.view.addSubview(logoImageView)
        logoImageView.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(80)
            make.width.height.equalTo(96)
            make.centerX.equalToSuperview()
        }
        self.view.addSubview(labelApp)
        labelApp.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.top.equalTo(logoImageView.snp.bottom).offset(16)
        }
        
        self.view.addSubview(labelICP)
        labelICP.snp.makeConstraints { make in
            let height = UICommonSdk.getIcp() == "" ? 0 : 20
            let offset = UICommonSdk.getIcp() == "" ? 0 : -4
            make.centerX.equalToSuperview()
            make.height.equalTo(height)
            make.bottom.equalTo(self.view.safeAreaLayoutGuide.snp.bottom).offset(offset)
        }
        self.view.addSubview(labelTerms)
        labelTerms.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalTo(labelICP.snp.top).offset(-4)
        }
        self.view.addSubview(labelPrivacy)
        labelPrivacy.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalTo(labelTerms.snp.top).offset(-4)
        }
        self.view.addSubview(labelTip)
        labelTip.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-2)
            make.bottom.equalTo(self.view.safeAreaLayoutGuide.snp.bottom)
        }
        
        self.labelApp.text = "\(UICommonSdk.getAppName()) v\(UICommonSdk.getVersionName())"
        let image = UICommonSdk.getAppIcon()
        logoImageView.image = image
        
        labelTip.text = "\(UICommonSdk.getLocale())|\(Locale.preferredLanguages[0])"
        
    }
    
    @objc func tapTerms(_ sender: Any) {
        let url = UICommonSdk.getUserTermsUrl()
        let control = WebViewController.load(title: UICommonSdk.getUserTermsTitle(), url: url)
        self.navigationController?.pushViewController(control, animated: true)
    }
    
    @objc func tapPrivacy(_ sender: Any) {
        let url = UICommonSdk.getPrivacyUrl()
        let control = WebViewController.load(title: UICommonSdk.getPrivacyTitle(), url: url)
        self.navigationController?.pushViewController(control, animated: true)
    }
    
    @objc func leftAction(_ sender: UIButton) {
        
        let _ = self.navigationController?.popViewController(animated: true)
    }
    
    public override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

}

