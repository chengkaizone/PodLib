//
//  NumberKeyboard.swift
//  LineCal
//
//  Created by tony on 2017/12/2.
//  Copyright © 2017年 chengkaizone. All rights reserved.
//

import UIKit
import AudioToolbox
import AVFoundation

private weak var currentFirstResponder: AnyObject?

public extension UIResponder {
    
    static func customFirstResponder() -> AnyObject? {
        currentFirstResponder = nil
        // 通过将target设置为nil，让系统自动遍历响应链
        // 从而响应链当前第一响应者响应我们自定义的方法
        UIApplication.shared.sendAction(#selector(findFirstResponder(_:)), to: nil, from: nil, for: nil)
        return currentFirstResponder
    }
    
    @objc func findFirstResponder(_ sender: AnyObject) {
        // 第一响应者会响应这个方法，并且将静态变量currentFirstResponder设置为自己
        currentFirstResponder = self
    }
}

@objc public protocol NumberKeyboardDelegate: NSObjectProtocol {
    
    /// default true
    @objc optional func numberKeyboard(_ numberKeyboard: NumberKeyboard!, shouldInsertText: String!) ->Bool
    /// default true
    @objc optional func numberKeyboardShouldReturn(_ numberKeyboard: NumberKeyboard!) ->Bool
    /// default true
    @objc optional func numberKeyboardShouldDeleteBackward(_ numberKeyboard: NumberKeyboard!) ->Bool
    
    @objc optional func numberKeyboardDeleteBackward(_ numberKeyboard: NumberKeyboard!)
    
    /// =(-1) +(0) -(1) *(2) /(3) enum不能用在@objc中
    @objc optional func numberKeyboardCalculate(_ numberKeyboard: NumberKeyboard!, key: Int)
    // 更多
    @objc optional func numberKeyboardMore(_ numberKeyboard: NumberKeyboard!)
    // 打开函数控制
    @objc optional func numberKeyboardFx(_ numberKeyboard: NumberKeyboard!)
    // 清除当前行
    @objc optional func numberKeyboardClear(_ numberKeyboard: NumberKeyboard!)
    // 清除所有
    @objc optional func numberKeyboardClearAll(_ numberKeyboard: NumberKeyboard!)
}

public extension UITextView {
    
    // 添加自定义键盘
    func addKeyboard(_ type: NumberKeyboard.KeyboardType = .decimal, isFirstResponder: Bool = false, delegate: NumberKeyboardDelegate? = nil, numberLength: Int? = nil) {
        
        if let inputView = self.inputView {
            if inputView.isKind(of: NumberKeyboard.self) {
                if (inputView as! NumberKeyboard).keyboardType == type {
                    return
                }
            }
        }
        self.resignFirstResponder()
        let keyboard = NumberKeyboard(type: type, impactFeedbackEnabled: NumberKeyboardSdk.impactFeedbackEnabled())
        keyboard.delegate = delegate
        if let numberLength = numberLength {
            keyboard.numberLength = numberLength
            if keyboard.numberLength > NumberKeyboard.MAX_NUMBER_LENGTH {
                keyboard.numberLength = NumberKeyboard.MAX_NUMBER_LENGTH
            }
        }
        self.autocorrectionType = .no
        self.inputView = keyboard
        if isFirstResponder {
            self.becomeFirstResponder()
        }
    }
    
    /// 数字键盘高度
    func numberKeyboardHeight() ->CGFloat {
        if let inputView = self.inputView {
            if inputView.isKind(of: NumberKeyboard.self) {
                return (inputView as! NumberKeyboard).keyboardHeight()
            }
        }
        return 0
    }
}

public extension UITextField {
    
    // 添加自定义键盘
    func addKeyboard(_ type: NumberKeyboard.KeyboardType = .decimal, isFirstResponder: Bool = false, delegate: NumberKeyboardDelegate? = nil, numberLength: Int? = nil) {
        
        if let inputView = self.inputView {
            if inputView.isKind(of: NumberKeyboard.self) {
                if (inputView as! NumberKeyboard).keyboardType == type {
                    return
                }
            }
        }
        self.resignFirstResponder()
        let keyboard = NumberKeyboard(type: type, impactFeedbackEnabled: NumberKeyboardSdk.impactFeedbackEnabled())
        keyboard.delegate = delegate
        if let numberLength = numberLength {
            keyboard.numberLength = numberLength
            if keyboard.numberLength > NumberKeyboard.MAX_NUMBER_LENGTH {
                keyboard.numberLength = NumberKeyboard.MAX_NUMBER_LENGTH
            }
        }
        self.autocorrectionType = .no
        self.inputView = keyboard
        if isFirstResponder {
            self.becomeFirstResponder()
        }
    }
    
    /// 数字键盘高度
    func numberKeyboardHeight() ->CGFloat {
        if let inputView = self.inputView {
            if inputView.isKind(of: NumberKeyboard.self) {
                return (inputView as! NumberKeyboard).keyboardHeight()
            }
        }
        return 0
    }
}


public class NumberKeyboard: UIInputView {

    static let rowHeight: CGFloat = 70
    static let rowHeightScientific: CGFloat = 40
    static let padMaximumWidth: CGFloat = 400
    // 科学键盘列数
    static let scientificColumn: Int = 8
    // 通用键盘列数
    static let normalColumn: Int = 4
    // 无关闭按钮纯数字
    static let numberColumn: Int = 3
    
    static let padBorder: CGFloat = 7
    static let padSpacing: CGFloat = 8
    static let fontSize: CGFloat = 24
    // 多字符减少的字体大小
    static let fontReduce: CGFloat = 6
    // d1d4d9
    static let defaultKeyboardBgColor = UIColor(red: 209/255.0, green: 212/255.0, blue: 217/255.0, alpha: 1)
    
    // 键盘类型
    public enum KeyboardType: Int {
        case decimal = 0
        case number = 1
        case hexadecimal = 2
        case calculator = 3
        case decimal_negative = 4
        // 基础计算器键盘
        case expression = 5
        // 科学计算器键盘
        case scientific = 6
        // 数字键盘(无关闭按钮)
        case number_retain = 7
        // 数据分析
        case data_retain = 8
    }
    
    lazy var isPad: Bool = {
        return UIDevice.current.userInterfaceIdiom == UIUserInterfaceIdiom.pad
    }()
    
    weak var _keyInput: UIKeyInput?
    public weak var keyInput: UIKeyInput? {
        
        set {
            _keyInput = newValue
        }
        
        get {
            
            if self._keyInput != nil {
                return self._keyInput
            }
            
            let keyInput = UIResponder.customFirstResponder()
            // 执行conforms反射判断
            if keyInput?.conforms(to: UITextInput.self) == false {
                self._keyInput = nil
                return nil
            }
            
            self._keyInput = keyInput as? UIKeyInput
            
            return keyInput as? UIKeyInput
        }
    }
    
    public weak var delegate: NumberKeyboardDelegate?
    
    // 最大有效数字长度
    static var MAX_NUMBER_LENGTH: Int = 33
    var numberLength: Int = NumberKeyboard.MAX_NUMBER_LENGTH
    var keyboardType: KeyboardType = .decimal
    //var hasEqual: Bool = false
    var keyCodes: [Key]!
    var keyButtons: [Key: LYNumberKeyboardButton]!
    
    var returnKeyTitle: String? = NumberKeyboardSdk.defaultReturnKeyTitle() {
        didSet {
            keyButtons[.done]?.setTitle(returnKeyTitle, for: .normal)
        }
    }
    var returnKeyButtonStyle: LYNumberKeyboardButton.LYNumberKeyboardButtonStyle = .done {
        didSet {
            keyButtons[.done]?.style = returnKeyButtonStyle
        }
    }
    // 是否启用触感反馈
    var impactFeedbackEnabled: Bool = false
    
    fileprivate var locale: Locale = Locale.current
    
    fileprivate var specialKeyHandler: (() ->Void)?
    
    convenience init() {
        self.init(type: NumberKeyboard.KeyboardType.decimal)
    }
    
    public init(type: KeyboardType, impactFeedbackEnabled: Bool = false) {
        super.init(frame: CGRect.zero, inputViewStyle: UIInputView.Style.keyboard)

        self.keyboardType = type
        self.impactFeedbackEnabled = impactFeedbackEnabled
        self.setup()
    }

    init(frame: CGRect) {
        super.init(frame: frame, inputViewStyle: UIInputView.Style.keyboard)

        self.setup()
    }

    public override init(frame: CGRect, inputViewStyle: UIInputView.Style) {
        super.init(frame: frame, inputViewStyle: inputViewStyle)

        setup()
    }

    public init(frame: CGRect, inputViewStyle: UIInputView.Style, locale: Locale) {

        super.init(frame: frame, inputViewStyle: UIInputView.Style.keyboard)

        self.locale = locale
        self.setup()
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        self.init(coder: aDecoder)
    }
    
    // 根据键盘类型返回按键列表, 必须保证是列的整数倍，便于计算高度
    func keys(type: KeyboardType) ->[Key] {
        
        var resultKeys: [Key]!
        switch type {
        case .decimal:
            resultKeys = [._1, ._2, ._3, .del/*2*/,
                          ._4, ._5, ._6, .none,
                          ._7, ._8, ._9, .done/*2*/,
                          .close, ._0, .point, .none
                        ]
            break
        case .number:
            resultKeys = [._1, ._2, ._3, .del/*2*/,
                          ._4, ._5, ._6, .none,
                          ._7, ._8, ._9, .done/*2*/,
                          .close, ._0, .none, .none
                        ]
            break
        case .number_retain:
            resultKeys = [._1, ._2, ._3,
                          ._4, ._5, ._6,
                          ._7, ._8, ._9,
                          .point, ._0, .del
                        ]
            break
        case .data_retain:
            resultKeys = [._1, ._2, ._3, .del/*2*/,
                          ._4, ._5, ._6, .none,
                          ._7, ._8, ._9, .clear/*2*/,
                          .comma, ._0, .point, .none
                        ]
            break
        case .hexadecimal:
            resultKeys = [.a, .b, .c, .d,
                          .e, .f, ._0, .point,
                          ._1, ._2, ._3, .del,
                          ._4, ._5, ._6, .done/*2*/,
                          ._7, ._8, ._9, .none
                        ]
            break
        case .decimal_negative:
            resultKeys = [._1, ._2, ._3, .del/*2*/,
                          ._4, ._5, ._6, .none,
                          ._7, ._8, ._9, .done/*2*/,
                          .reduce, ._0, .point, .none]
            break
            
        case .expression, .calculator:
            resultKeys = [.bracketleft, .bracketright, .clear, .del,
                ._7, ._8, ._9, .divide,
                ._4, ._5, ._6, .multiply,
                ._1, ._2, ._3, .reduce,
                .percent, ._0, .point, .add]
            break
        case .scientific:
            resultKeys = [.pow, .pow3, .powy, .powe, .bracketleft, .bracketright, .clear, .del,
                          .sqrt, .cbrt, .sqrty, .powten, ._7, ._8, ._9, .divide,
                          .ln, .log, .fac, .down, ._4, ._5, ._6, .multiply,
                          .sin, .cos, .tan, .xe, ._1, ._2, ._3, .reduce,
                          .asin, .acos, .atan, .pi, .percent, ._0, .point, .add]
            break
        }
        
        return resultKeys
    }
    
    class func symbol(key: Int) ->String {
        
        switch key {
        case 0:
            return "+"
        case 1:
            return "-"
        case 2:
            if NumberKeyboardSdk.isZhCN() {
                return "×"
            } else {
                return "*"
            }
            
        case 3:
            if NumberKeyboardSdk.isZhCN() {
                return "÷"
            } else {
                return "/"
            }
        default:
            break
        }
        
        return ""
    }
    
    class func getKey(symbol: String) ->Int {
        
        switch symbol {
        case "+":
            return 0
        case "-":
            return 1
        case "*", "x":
            return 2
        case "/", "÷":
            return 3
        default:
            break
        }
        
        return -1
    }
    
    // 删除按钮是否为灰色背景
    private func isDelGray() -> Bool {
        return keyboardType == .decimal
            || keyboardType == .decimal_negative
            || keyboardType == .number
    }
    
    // 创建按键
    func makeButton(key: Key) ->LYNumberKeyboardButton {
        
        var button = LYNumberKeyboardButton.keyboardButton(style: .white)
        button.key = key
        
        let text = key.codeDraw()
        var reduce: CGFloat = 0
        switch(key) {
        case ._0, ._1, ._2, ._3, ._4, ._5, ._6, ._7, ._8, ._9, .clear, .clearAll:
            reduce = 0
            break
        case .point:
            reduce = -NumberKeyboard.fontReduce
            break
        default:
            reduce = NumberKeyboard.fontReduce
            break
        }
        
        let buttonFont = UIFont.systemFont(ofSize: NumberKeyboard.fontSize - reduce, weight: .light)
        
        switch key {
        case .point:
            var decimalSeparator: String? = (locale as NSLocale).object(forKey: NSLocale.Key.decimalSeparator) as? String
            decimalSeparator = decimalSeparator == nil ? "." : decimalSeparator!
            button.setTitle(decimalSeparator, for: .normal)
            break
        case .del:
            let delImage = NumberKeyboard.keyboardImage(name: "DeleteKey")
            if isDelGray() {
                button = LYNumberKeyboardButton.keyboardButton(style: .gray)
                button.key = key
            }
            
            button.setTitle(text, for: .normal)
            button.setImage(delImage?.withRenderingMode(.alwaysTemplate), for: .normal)
            button.action = #selector(backspaceRepeat(_:))
            button.actionTarget = self
            break
        case .close:
            let dismissImage = NumberKeyboard.keyboardImage(name: "DismissKey")
            button = LYNumberKeyboardButton.keyboardButton(style: .gray)
            button.key = key
            button.setTitle(text, for: .normal)
            button.setImage(dismissImage, for: .normal)
            break
        case .done:
            button = LYNumberKeyboardButton.keyboardButton(style: .done)
            button.key = key
            let doneButtonFont = UIFont.systemFont(ofSize: NumberKeyboard.fontSize - NumberKeyboard.fontReduce)
            button.titleLabel?.font = doneButtonFont
            button.setTitle(returnKeyTitle, for: .normal)
            break
        case .eq:
            button = LYNumberKeyboardButton.keyboardButton(style: .done)
            button.key = key
            button.setTitle(text, for: .normal)
            button.titleLabel?.font = buttonFont
            break
        case .add:
            let addImage = NumberKeyboard.keyboardImage(name: "AddKey")
            let addImage2 = NumberKeyboard.keyboardImage(name: "AddKey_p")
            button = LYNumberKeyboardButton.keyboardButton(style: .done)
            button.setImage(addImage2, for: .normal)
            button.setImage(addImage, for: .highlighted)
            button.key = key
            button.setTitle(text, for: .normal)
            break
        case .reduce:
            let reduceImage = NumberKeyboard.keyboardImage(name: "ReduceKey")
            button = LYNumberKeyboardButton.keyboardButton(style: .white)
            button.key = key
            button.setTitle(text, for: .normal)
            button.setImage(reduceImage, for: .normal)
            break
        case .multiply:
            let multiplyImage = NumberKeyboard.keyboardImage(name: "MultiplyKey")
            button = LYNumberKeyboardButton.keyboardButton(style: .white)
            button.key = key
            button.setTitle(text, for: .normal)
            button.setImage(multiplyImage, for: .normal)
            break
        case .divide:
            let divideImage = NumberKeyboard.keyboardImage(name: "DivideKey")
            button = LYNumberKeyboardButton.keyboardButton(style: .white)
            button.key = key
            button.setTitle(text, for: .normal)
            button.setImage(divideImage, for: .normal)
            break
        case .more:
            var moreImage = NumberKeyboard.keyboardImage(name: "MoreKey")
            moreImage = moreImage?.withRenderingMode(.alwaysTemplate)
            button = LYNumberKeyboardButton.keyboardButton(style: .white)
            button.key = key
            button.setTitle(text, for: .normal)
            button.tintColor = NumberKeyboardSdk.getThemeColor()
            button.setImage(moreImage, for: .normal)
            break
        case .fx:
            button.setTitleColor(NumberKeyboardSdk.getThemeColor(), for: .normal)
            button.setTitle(text, for: .normal)
            button.titleLabel?.font = buttonFont
            break
        case .clear:
            button.setTitleColor(NumberKeyboardSdk.getThemeColor(), for: .normal)
            button.setTitle(text, for: .normal)
            button.titleLabel?.font = buttonFont
            break
        case .clearAll:
            button.setTitleColor(NumberKeyboardSdk.getThemeColor(), for: .normal)
            button.setTitle(text, for: .normal)
            button.titleLabel?.font = buttonFont
            break
        case .none:
            break
        default:
            button.setTitle(text, for: .normal)
            button.titleLabel?.font = buttonFont
            break
        }
        
        button.layer.borderColor = UIColor(white: 0.0, alpha: 0.1).cgColor
        button.layer.borderWidth = 0.2
        button.layer.shadowOffset = CGSize(width: 0, height: 0)
        button.isExclusiveTouch = true // 是否唯触摸
        if key != Key.del {
            button.addTarget(self, action: #selector(buttonInputForKey(_:)), for: .touchUpInside)
            button.addTarget(self, action: #selector(buttonPlayClick(_:)), for: .touchUpInside)
        }
        return button
    }

    func setup() {
        self.backgroundColor = isPad ? NumberKeyboard.defaultKeyboardBgColor : .white
        self.keyCodes = self.keys(type: self.keyboardType)
        self.keyButtons = [Key: LYNumberKeyboardButton]()
        
        for key in keyCodes {// 创建所有的按键
            let button = self.makeButton(key: key)
            keyButtons[key] = button
            self.addSubview(button)
            if key == .none {
                self.sendSubviewToBack(button)
            }
        }
        
        let highlightGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handleHighlightGestureRecognizer(_:)))
        self.addGestureRecognizer(highlightGestureRecognizer)
        self.sizeToFit()
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()

        self.layoutForCal()
    }
    
    @objc func buttonPlayClick(_ sender: UIButton) {
        
        if(impactFeedbackEnabled) {
            NumberKeyboardSdk.impact()
        }
        
        switch NumberKeyboardSdk.getVoiceEffectType() {
        case 2:
            break
        case 1: // 语音播报
            let button = sender as! LYNumberKeyboardButton
            let key = button.key

            switch key {
            case ._0, ._1, ._2, ._3, ._4, ._5, ._6, ._7, ._8, ._9, .point, .a, .b, .c, .d, .e, .f:
                NumberKeyboardSdk.speakText(text: key.rawValue)
                break
            case .add:
                NumberKeyboardSdk.speakText(text: NumberKeyboardSdk.keyAdd())
                break
            case .reduce:
                NumberKeyboardSdk.speakText(text: NumberKeyboardSdk.keyReduce())
                break
            case .multiply:
                NumberKeyboardSdk.speakText(text: NumberKeyboardSdk.keyMultiply())
                break
            case .divide:
                NumberKeyboardSdk.speakText(text: NumberKeyboardSdk.keyDivide())
                break
            case .eq:
                NumberKeyboardSdk.speakText(text: NumberKeyboardSdk.keyEq())
                break
            case .fx, .del, .done, .close, .clear, .clearAll, .more:
                NumberKeyboardSdk.playSound()
                break
            default:
                break
            }
            break
        default:
            NumberKeyboardSdk.playSound()
            break
        }
    }
    
    /**
    * 获取按钮行高
     */
    fileprivate func getRowHeight() -> CGFloat {
        let rowHeight = (keyboardType == .scientific && !isPad) ? NumberKeyboard.rowHeightScientific : NumberKeyboard.rowHeight
        return rowHeight
    }
    
    // 每一行的按键个数
    fileprivate func getColumnCount() -> Int {
        if keyboardType == .number_retain {
            return NumberKeyboard.numberColumn
        }
        let numbersPerLine: Int = keyboardType == .scientific ? NumberKeyboard.scientificColumn : NumberKeyboard.normalColumn
        return numbersPerLine
    }
    
    fileprivate func layoutForCal() {
        let bounds = self.bounds
        let numbersPerLine: Int = getColumnCount()
        let spacing = isPad ? NumberKeyboard.padBorder : 0.0
        let padWidth = keyboardType == .scientific ? NumberKeyboard.padMaximumWidth * 1.5 : NumberKeyboard.padMaximumWidth
        let maximumWidth = isPad ? padWidth : bounds.width
        let width = min(maximumWidth, bounds.width)
        let contentRect = CGRect(x: round((bounds.width - width) / 2.0), y: spacing, width: width, height: bounds.height - spacing * 2.0)
        let columnWidth = CGFloat(Int(contentRect.width / CGFloat(numbersPerLine))) // 这里必须要处理成整数、否则布局边框会出现不及预期的情况
        let columnWidthEnd = contentRect.width - columnWidth * CGFloat(numbersPerLine - 1)
        let rowHeight = getRowHeight()
        let numberSize = CGSize(width: columnWidth, height: rowHeight)
        
        for i in 0..<keyCodes.count {
            let key = keyCodes[i]
            let button = keyButtons[key]
            let rowHeight = handleKeyHeight(key)
            let isEnd = (i + 1) % numbersPerLine == 0
            let targetWidth = isEnd ? columnWidthEnd : columnWidth
            var rect = CGRect(origin: CGPoint.zero, size: CGSize(width: targetWidth, height: rowHeight))
            rect.origin.y = numberSize.height * CGFloat(i / numbersPerLine)
            rect.origin.x = numberSize.width * CGFloat(i % numbersPerLine)
            button?.frame = self.makeButtonRect(rect: rect, contentRect: contentRect)
        }
        
    }
    
    /// 计算按键高度
    /// - Parameter key:
    /// - Returns:
    fileprivate func handleKeyHeight(_ key: Key) -> CGFloat {
        if key != .del && key != .done && key != .add && key != .clear {
            return getRowHeight()
        }
        let rowHeightExtra = getRowHeight() * 2
        
        switch keyboardType {
        case .expression, .calculator:
            if key == .add {
                return getRowHeight()
            }
            break
        case .scientific:
            if key == .add {
                return getRowHeight()
            }
            break
        case .hexadecimal:
            if key == .done {
                return rowHeightExtra
            }
            break
        case .number, .decimal, .decimal_negative:
            if key == .del || key == .done {
                return rowHeightExtra
            }
            break
        case .data_retain:
            if key == .del || key == .clear {
                return rowHeightExtra
            }
            break
        case .number_retain:
            break
        }
        return getRowHeight()
    }
    
    // 重新创建按钮区域
    fileprivate func makeButtonRect(rect: CGRect, contentRect: CGRect) ->CGRect {
        var resultRect = rect.offsetBy(dx: contentRect.origin.x, dy:  contentRect.origin.y)
        if isPad {
            let inset = NumberKeyboard.padSpacing / 2.0
            //CGRectInset 正数向内推进，负数向外扩展
            resultRect = resultRect.insetBy(dx: inset, dy: inset)
        }
        
        return resultRect
    }
    
    @objc func backspaceRepeat(_ sender: UIButton) {
        
        if self.keyInput?.hasText == false {
            return
        }
        self.buttonPlayClick(sender)
        self.buttonInputForKey(sender)
    }
    
    // 是否限制数字输入
    private func isLimitNumber() -> Bool {
        let flag = keyboardType == .expression
            || keyboardType == .scientific
            || keyboardType == .data_retain
        if (flag) {
            return false
        }
        return true
    }
    
    @objc func buttonInputForKey(_ sender: UIButton) {
        
        var key: Key!
        for (_key, button) in self.keyButtons {
            
            if sender == button {
                key = _key
                break
            }
        }
        
        if key == nil {
            return
        }
        
        if key == Key.none {
            return
        }
        
        guard let keyInput: UIKeyInput = self.keyInput else {
            return
        }
        
        switch key! {
        case .del:
            if self.delegate != nil {
                if self.delegate!.numberKeyboardShouldDeleteBackward != nil {
                    if self.delegate!.numberKeyboardShouldDeleteBackward!(self) {
                        if keyInput.hasText {
                            keyInput.deleteBackward()
                            sendInputEvent()
                            self.delegate?.numberKeyboardDeleteBackward?(self)
                        }
                    }
                } else {
                    if keyInput.hasText {
                        keyInput.deleteBackward()
                        sendInputEvent()
                        self.delegate?.numberKeyboardDeleteBackward?(self)
                    }
                }
            } else {
                keyInput.deleteBackward()
                sendInputEvent()
            }
            break
        case .done:
            if self.delegate != nil {
                if self.delegate!.numberKeyboardShouldReturn != nil {
                    if self.delegate!.numberKeyboardShouldReturn!(self) {
                        self.dismissKeyboard(sender)
                    }
                } else {
                    self.dismissKeyboard(sender)
                }
                
            } else {
                self.dismissKeyboard(sender)
            }
            break
        case .close:
            self.dismissKeyboard(sender)
            break
        case .eq:
            if self.delegate != nil {
                self.delegate?.numberKeyboardCalculate?(self, key: -1)
            }
            break
        case .fx:
            if self.delegate != nil {
                self.delegate?.numberKeyboardFx?(self)
            }
            break
        case .clear:
            if self.delegate != nil {
                self.delegate?.numberKeyboardClear?(self)
            }
            break
        case .clearAll:
            if self.delegate != nil {
                self.delegate?.numberKeyboardClearAll?(self)
            }
            break
        case .more:
            if self.delegate != nil {
                self.delegate?.numberKeyboardMore?(self)
            }
            break
        default:
            let text = key!.codeInput()
            if self.delegate != nil {
                switch key! {
                case .add:
                    self.delegate?.numberKeyboardCalculate?(self, key: 0)
                    break
                case .reduce:
                    self.delegate?.numberKeyboardCalculate?(self, key: 1)
                    break
                case .multiply:
                    self.delegate?.numberKeyboardCalculate?(self, key: 2)
                    break
                case .divide:
                    self.delegate?.numberKeyboardCalculate?(self, key: 3)
                    break
                default: break
                }
                if self.delegate?.numberKeyboard != nil {
                    if self.delegate!.numberKeyboard!(self, shouldInsertText: text) {
                        keyInput.insertText(text)
                        self.checkCursor(keyInput: keyInput, key: key)
                        sendInputEvent()
                    }
                } else {
                    self.checkInput(keyInput: keyInput, key: key)
                }
            } else {
                self.checkInput(keyInput: keyInput, key: key)
            }
            break
        }        
    }
    
    // 发送输入事件
    fileprivate func sendInputEvent() {
        guard let keyInput = self.keyInput else {
            return
        }
        if keyInput is UITextView {
            let textView = keyInput as! UITextView
            textView.delegate?.textViewDidChange?(textView)
        } else if keyInput is UITextField {
            let textField = keyInput as! UITextField
            textField.delegate?.textFieldDidEndEditing?(textField)
        }
    }
    
    fileprivate func checkInput(keyInput: UIKeyInput, key: Key) {
        var str: String = ""
        if let textField = keyInput as? UITextField {
            str = textField.text ?? ""
        } else if let textView = keyInput as? UITextView {
            str = textView.text
        }

        switch key {
        case .add, .reduce, .multiply, .divide:
            if !isLimitNumber() || (key == .reduce && keyboardType == .decimal_negative) {
                let text = key.codeInput()
                keyInput.insertText(text)
                sendInputEvent()
            }
            break
        default:
            let text = key.codeInput()
            if isLimitNumber() {
                if str.replacingOccurrences(of: ".", with: "").count > numberLength {
                    return
                }
            }
            keyInput.insertText(text)
            self.checkCursor(keyInput: keyInput, key: key)
            sendInputEvent()
            break
        }
    }
    
    fileprivate func checkCursor(keyInput: UIKeyInput, key: Key) {
        if key != .logxy && key != .log {
            return
        }
        
        let textView = keyInput as! UITextView
        textView.delegate?.textViewDidChange?(textView)
        if keyInput is UITextField {
            let textField = keyInput as! UITextField
            guard let textRange = textView.selectedTextRange else {
                return
            }
            guard let selectionEnd = textView.position(from: textRange.end, offset: -1) else {
                return
            }
            textField.selectedTextRange = textView.textRange(from: selectionEnd, to: selectionEnd)
        } else if keyInput is UITextView {
            let textView = keyInput as! UITextView
            guard let textRange = textView.selectedTextRange else {
                return
            }
            guard let selectionEnd = textView.position(from: textRange.end, offset: -1) else {
                return
            }
            textView.selectedTextRange = textView.textRange(from: selectionEnd, to: selectionEnd)
        }
    }
    
    @objc func dismissKeyboard(_ sender: UIButton?) {
        
        guard let keyInput = self.keyInput else {
            return
        }
        
        if keyInput.isKind(of: UIResponder.classForCoder()) {
            (keyInput as! UIResponder).resignFirstResponder()
        }
    }
    
    @objc func handleHighlightGestureRecognizer(_ recognizer: UIPanGestureRecognizer) {
    
        let point = recognizer.location(in: self)
        
        if recognizer.state == .changed || recognizer.state == .ended {
            
            for (_, button) in self.keyButtons {
                
                let points = button.frame.contains(point) && !button.isHidden
                
                if recognizer.state == .changed {
                    button.isHighlighted = points
                } else {
                    button.isHighlighted = false
                }
                
                if recognizer.state == .ended && points {
                    button.sendActions(for: .touchUpInside)
                }
            }
        }
        
    }
    
    /// 获取底部安全区的值
    public func safeAreaBottom() -> CGFloat {
        var safeAreaBottom: CGFloat = 0
        if let window = UIApplication.shared.delegate?.window {
            safeAreaBottom = window!.safeAreaInsets.bottom
        }
        return safeAreaBottom
    }
    
    /// 获取键盘高度
    public func keyboardHeight() ->CGFloat {
        
        if isPad {
            return self.bounds.height
        }
        
        return self.bounds.height
    }
    
    /// 计算键盘的整体高度
    public override func sizeThatFits(_ size: CGSize) -> CGSize {
        let keys = self.keys(type: self.keyboardType)
        let rows: CGFloat = CGFloat(keys.count) / CGFloat(getColumnCount())
        var extraHeight: CGFloat = 0
        if isPad { // ipad添加额外高度避免被撤销功能遮挡
            extraHeight = 48
        }
        let spacing = isPad ? NumberKeyboard.padBorder : 0.0
        var resultSize = size
        resultSize.height = getRowHeight() * rows + spacing * 2.0 + safeAreaBottom() + extraHeight
        if resultSize.width == 0.0 {
            resultSize.width = UIScreen.main.bounds.size.width
        }
        
        return resultSize
    }

    private static let imageBundle = Bundle(path: Bundle(for: NumberKeyboard.self).path(forResource: "NumberKeyboard", ofType: "bundle")!)
    
    // 通过文件名和后缀获取图片
    fileprivate static func keyboardImage(name: String) ->UIImage? {

        if let path = imageBundle?.path(forResource: name, ofType: "png") {
            return UIImage(contentsOfFile: path)
        }

        return nil
    }
}

extension NumberKeyboard: UIInputViewAudioFeedback {
    
    public var enableInputClicksWhenVisible: Bool {
        get {
            return true
        }
    }
}

// 按键
enum Key: String {
    case _0 = "0"
    case _1 = "1"
    case _2 = "2"
    case _3 = "3"
    case _4 = "4"
    case _5 = "5"
    case _6 = "6"
    case _7 = "7"
    case _8 = "8"
    case _9 = "9"
    case point = "."
    // 16进制
    case a = "A"
    case b = "B"
    case c = "C"
    case d = "D"
    case e = "E"
    case f = "F"
    // 回退一格
    case del = "del"
    case close = "close"
    case done = "done"
    // =
    case eq = "="
    // +
    case add = "add"
    // -
    case reduce = "reduce"
    // x
    case multiply = "multiply"
    // /
    case divide = "divide"
    
    // ƒ 函数符号
    case fx = "f(x)"
    // 清空一行 C
    case clear = "clear"
    // 清空所有 AC
    case clearAll = "clearAll"
    // 更多
    case more = "more"
    case comma = ","
    
    case none = ""
    
    case pow = "x²"
    case pow3 = "x³"
    case powy = "xʸ"
    case sqrt = "²√x"
    case cbrt = "³√x"
    case sqrty = "ʸ√x"
    case down = "1/x"
    case fac = "x!"
    case pi = "π"
    case xe = "e"
    case ln = "ln"
    case log = "log"
    case sin = "sin"
    case cos = "cos"
    case tan = "tan"
    case cot = "cot"
    case asin = "sin⁻¹"
    case acos = "cos⁻¹"
    case atan = "tan⁻¹"
    case acot = "cot⁻¹"
    case powe = "eˣ"
    case powten = "10ˣ"
    case percent = "%"
    case logxy = "logxʸ"
    case log2 = "log2"
    case log10 = "log10"

    case bracketleft = "("
    case bracketright = ")"
    
    func codeDraw() -> String {
        var text = ""
        switch self {
        case .more, .add, .reduce, .multiply, .divide, .del, .close:
            text = ""
            break
        case .clear, .clearAll:
            text = "C"
        default:
            text = self.rawValue
        }
        return text
    }
    
    func codeInput() -> String {
        switch self {
        case .none, .close, .done, .del, .clear, .clearAll, .fx, .eq:
            return "";
        case .comma: return ","
        case .add: return "+"
        case .reduce: return "-";
        case .multiply:
            if (NumberKeyboardSdk.isZhCN()) {
                return "x";
            } else {
                return "*";
            }
        case .divide:
            if (NumberKeyboardSdk.isZhCN()) {
                return "÷";
            } else {
                return "/";
            }
        case .pow: return "^2";
        case .pow3: return "^3";
        case .powy: return "^";
        case .sqrt: return "2√";
        case .cbrt: return "3√";
        case .sqrty: return "√";
        case .down: return "^(-1)";
        case .fac: return "!";
        case .pi: return "π";
        case .xe: return "e";
        case .powe: return "e^";
        case .powten: return "10^";
        case .sin: return "sin(";
        case .cos: return "cos(";
        case .tan: return "tan(";
        case .cot: return "cot(";
        case .asin: return "sin⁻¹(";
        case .acos: return "cos⁻¹(";
        case .atan: return "tan⁻¹(";
        case .acot: return "cot⁻¹(";
        case .percent: return "%";
        case .ln: return "ln(";
        case .log: return "log(,";
        case .logxy: return "log(,";
        case .log2: return "log(2)";
        case .log10: return "log(10)";
        case .bracketleft: return "(";
        case .bracketright: return ")";
        default:
            let code = self.rawValue
            return code
        }
    }
    
}

class LYNumberKeyboardButton: UIButton {
    
    enum LYNumberKeyboardButtonStyle: UInt {// 按钮风格
        case white = 0
        case gray = 1
        case done = 2
    }
    
    var key: Key = .none
    
    var repeatDelay: TimeInterval = 0.3
    var repeatInterval: TimeInterval = 0.1
    
    var action: Selector? = nil
    var repeatEndedAction: Selector? = nil
    weak var actionTarget: NSObject? = nil
    
    var fillColor: UIColor!
    var highlightedFillColor: UIColor!
    
    var controlColor: UIColor!
    var highlightedControlColor: UIColor!
    
    lazy var isPad: Bool = {
        return UIDevice.current.userInterfaceIdiom == UIUserInterfaceIdiom.pad
    }()
    
    override var isHighlighted: Bool {
        didSet {
            self.updateButtonAppearance()
        }
    }
    
    var style: LYNumberKeyboardButtonStyle = .white {
        didSet {
            self.buttonStyleDidChange()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setup()
        self.buttonStyleDidChange()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        //fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        
    }
    
    class func keyboardButton(style: LYNumberKeyboardButtonStyle) ->LYNumberKeyboardButton {
        
        let button = LYNumberKeyboardButton(type: .custom)
        button.style = style
        
        return button
    }

    func buttonStyleDidChange() {
        
        var fillColor: UIColor!
        var highlightedFillColor: UIColor = UIColor(red: 0.933, green: 0.933, blue: 0.933, alpha: 1)
        
        switch self.style {
        case .white:
            fillColor = UIColor.white
            if isPad {
                highlightedFillColor = UIColor(red: 0.85, green: 0.85, blue: 0.85, alpha: 1)
            }
            break
        case .gray:
            if isPad {
                fillColor = UIColor(red: 0.674, green: 0.7, blue: 0.744, alpha: 1)
            } else {
                fillColor = UIColor(red: 0.81, green: 0.837, blue: 0.86, alpha: 1)
            }
            break
        case .done:
            fillColor = NumberKeyboardSdk.getThemeColor()
            break
        }
        var controlColor: UIColor = UIColor.black
        let highlightedControlColor: UIColor = UIColor.black
        
        if self.style == .done {
            controlColor = UIColor.white
        }
        
        self.setTitleColor(controlColor, for: .normal)
        self.setTitleColor(highlightedControlColor, for: .selected)
        self.setTitleColor(highlightedControlColor, for: .highlighted)
        
        self.fillColor = fillColor
        self.highlightedFillColor = highlightedFillColor
        self.controlColor = controlColor
        self.highlightedControlColor = highlightedControlColor
        
        if isPad {
            
            let buttonLayer = self.layer
            buttonLayer.cornerRadius = 4.0
            buttonLayer.shadowColor = UIColor(red: 0.533, green: 0.541, blue: 0.556, alpha: 1).cgColor
            buttonLayer.shadowOffset = CGSize(width: 0, height: 1.0)
            buttonLayer.shadowOpacity = 1.0
            buttonLayer.shadowRadius = 0.0
        }
        
        self.updateButtonAppearance()
    }
    
    override func willMove(toWindow newWindow: UIWindow?) {
        super.willMove(toWindow: newWindow)
        
        if newWindow != nil {
            self.updateButtonAppearance()
        }
    }
    
    func updateButtonAppearance() {
        
        if self.isHighlighted || self.isSelected {
            self.backgroundColor = self.highlightedFillColor
            self.imageView?.tintColor = self.controlColor
        } else {
            self.backgroundColor = self.fillColor
            self.imageView?.tintColor = self.highlightedControlColor
        }
    }
    
    func setup() {
        self.repeatDelay = 1
        self.repeatInterval = 0.1
        self.addTarget(self, action: #selector(buttonTouchedDown), for: .touchDown)
        self.addTarget(self, action: #selector(buttonTouchedUp), for: [.touchUpInside, .touchUpOutside, .touchCancel])
    }
    
    /// 取消前一个selector执行
    func cancelNextAction() {
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(triggerActionRepeat), object: nil)
    }
    
    @objc func buttonTouchedDown() {
        guard let action = self.action, let target = self.actionTarget else {
            return
        }
        self.sendAction(action, to: target, for: nil)
        self.perform(#selector(triggerActionRepeat), with: nil, afterDelay: self.repeatDelay)
    }
    
    /// 触发重复调用
    @objc func triggerActionRepeat() {
        guard let action = self.action, let target = self.actionTarget else {
            return
        }
        self.sendAction(action, to: target, for: nil)
        self.perform(#selector(triggerActionRepeat), with: nil, afterDelay: self.repeatInterval)
    }
    
    @objc func buttonTouchedUp() {
        self.cancelNextAction()
        guard let repeatEndedAction = self.repeatEndedAction, let target = self.actionTarget else {
            return
        }
        self.sendAction(repeatEndedAction, to: target, for: nil)
    }
    
}

