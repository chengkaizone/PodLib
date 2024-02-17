//
//  FeedbackViewController.swift
//  LineCal
//
//  Created by tony on 2021/12/6.
//  Copyright © 2021 chengkaizone. All rights reserved.
//

import UIKit
import SnapKit

/**
 * 扫码进用户群
 */
public class FeedbackViewController: BaseViewController {
    
    lazy var titleTextField: UITextField = {
        return makeTextInput(UICommonSdk.getFeedbackSubject(), tintColor: UICommonSdk.getPrimaryColor())
    }()
    
    lazy var contentTextView: UITextView = {
        let textView = CommonPlaceholderTextView(frame: .zero)
        textView.font = UIFont.systemFont(ofSize: 14)
        textView.textColor = UIColor.darkGray
        textView.textAlignment = .left
        textView.isEditable = true
        textView.backgroundColor = UIColor.black.resetAlpha(alpha: 0.1)
        textView.placeholderColor = UIColor.lightGray
        textView.tintColor = UICommonSdk.getPrimaryColor()
        textView.placeholder = UICommonSdk.getFeedbackContent()
        return textView
    }()
    
    lazy var contactTextField: UITextField = {
        return makeTextInput(UICommonSdk.getFeedbackContact(), tintColor: UICommonSdk.getPrimaryColor())
    }()
    
    lazy var buttonSubmit: UIButton = {
        let button = UIButton(type: .custom)
        button.setBackgroundImage(primaryColor().bitmap(), for: .normal)
        button.setBackgroundImage(primaryColor().resetAlpha(alpha: 0.9).bitmap(), for: .highlighted)
        button.setTitleColor(.white, for: UIControl.State())
        button.setTitle(UICommonSdk.getSubmit(), for: UIControl.State())
        button.layer.cornerRadius = 4
        button.layer.masksToBounds = true
        button.addTarget(self, action: #selector(submitAction(_:)), for: .touchUpInside)
        return button
    }()
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.initWithViewController(self, title: UICommonSdk.getFeedbackTitle(), primaryColor: UICommonSdk.getPrimaryColor())
        self.navigationController?.navigationBar.leftBarAction(self, image: UICommonSdk.getNavBackIcon(), action: #selector(leftAction(_:)))
        self.view.backgroundColor = UICommonSdk.getViewBackgroundColor()
        
        setup()
    }
    
    deinit {
        ///
    }
    
    func makeTextInput(_ placeholder: String, tintColor: UIColor, isSecure: Bool = false) -> UITextField {
        let textField = UITextField(frame: .zero)
        textField.font = UIFont.systemFont(ofSize: 16)
        textField.textAlignment = .left
        textField.tintColor = tintColor
        textField.textColor = UIColor(argb: "#202020")
        textField.placeholder = placeholder
        textField.autocapitalizationType = .none
        textField.autocorrectionType = .no
        if isSecure {
            textField.isSecureTextEntry = isSecure
        }
        textField.keyboardType = .default
        return textField
    }
    
    @objc func leftAction(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    fileprivate func setup() {
        self.view.addSubview(titleTextField)
        titleTextField.snp.makeConstraints { make in
            make.left.top.equalToSuperview().offset(20)
            make.right.equalToSuperview().offset(-20)
            make.height.equalTo(40)
        }
        self.view.addSubview(contentTextView)
        contentTextView.snp.makeConstraints { make in
            make.top.equalTo(titleTextField.snp.bottom).offset(20)
            make.left.equalToSuperview().offset(20)
            make.right.equalToSuperview().offset(-20)
            make.height.equalTo(100)
        }
        self.view.addSubview(contactTextField)
        contactTextField.snp.makeConstraints { make in
            make.top.equalTo(contentTextView.snp.bottom).offset(40)
            make.left.equalToSuperview().offset(20)
            make.right.equalToSuperview().offset(-20)
            make.height.equalTo(40)
        }
        self.view.addSubview(buttonSubmit)
        buttonSubmit.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(20)
            make.right.equalToSuperview().offset(-20)
            make.height.equalTo(40)
            make.bottom.equalTo(self.view.safeAreaLayoutGuide.snp.bottom).offset(-16)
        }
    }
    
    @objc func submitAction(_ sender: UIButton) {
        self.doSubmit()
    }
    
    private func doSubmit() {
        guard let content = contentTextView.text?.trim(), content.count >= 10, content.count <= 500 else {
            UICommonSdk.showHint(UICommonSdk.getFeedbackContent(), controller: self)
            return
        }
        let title = titleTextField.text?.trim() ?? ""
        let contact = contactTextField.text?.trim() ?? ""
        UICommonSdk.addFeedback(controller: self, title: title, content: content, contact: contact)
    }
    
}
