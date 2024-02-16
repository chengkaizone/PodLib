//
//  LYSubtitleView.swift
//  LYCompositionKit
//
//  Created by tony on 16/3/4.
//  Copyright © 2016年 chengkai. All rights reserved.
//

import UIKit

@objc public protocol LYSubtitleViewDelegate: NSObjectProtocol {
    
    func subtitleViewDidMoveStart(_ subtitleView: LYSubtitleView)
    
    func subtitleViewDidMoving(_ subtitleView: LYSubtitleView)
    
    func subtitleViewDidMoveEnd(_ subtitleView: LYSubtitleView)
    
    func subtitleViewDidTap(_ subtitleView:  LYSubtitleView)
    
    func subtitleViewDidDelete(_ subtitleView: LYSubtitleView)
    
    func subtitleViewDidEdit(_ subtitleView: LYSubtitleView)
    
    // 开始旋转缩放
    func subtitleViewDidResizeStart(_ subtitleView: LYSubtitleView)
    // 处于旋转和缩放中
    func subtitleViewDidResizing(_ subtitleView: LYSubtitleView)
    // 结束旋转缩放
    func subtitleViewDidResizeEnd(_ subtitleView: LYSubtitleView)
    
}

open class LYSubtitleView: UIView {
    
    open weak var delegate: LYSubtitleViewDelegate?
    
    fileprivate let controlSize:CGFloat = 30
    fileprivate var btDelete:UIButton!
    /// 字幕设置按钮
    open var btEdit:UIButton!
    fileprivate var btControl:UIButton!
    
    fileprivate var borderWidth:CGFloat = 2
    fileprivate var subtitleBorder: UIView!
    fileprivate var subtitleLabel:UILabel!
    
    fileprivate var startMovePoint:CGPoint!
    
    fileprivate var labelAspectRatio:CGFloat!
    
    /** 是否打开删除按钮 default is false */
    open var deleteEnabled: Bool = false {
        didSet {
            btDelete.isHidden = !deleteEnabled
        }
    }
    
    /** 字幕文本 */
    open var text:String = "" {
        didSet {
            setupAttribute(text as NSString)
        }
    }
    
    /** 字符串所需要的尺寸 */
    open var stringSize: CGSize {
        get {
            return CGSize(width: subtitleLabel.frame.width, height: subtitleLabel.frame.height)
        }
    }
    
    fileprivate var shouldResizeAttribute: Bool = true
    /** 字幕字体 */
    open var font:UIFont = UIFont.systemFont(ofSize: 18) {
        didSet {
            if subtitleLabel == nil || subtitleLabel.text == nil {
                return
            }
            let text = subtitleLabel.text! as NSString
            if text.length == 0 {
                return
            }
            
            if shouldResizeAttribute {
                setupAttribute(text)
            }
        }
    }
    
    /** 字幕颜色 */
    open var textColor:UIColor = UIColor.white {
        didSet {
            if subtitleLabel == nil {
                return
            }
            
            subtitleLabel.textColor = textColor
        }
    }
    
    open var textBackgroundColor: UIColor = UIColor.clear {
        didSet {
            if subtitleLabel == nil {
                return
            }
            
            subtitleLabel.backgroundColor = textBackgroundColor
        }
    }
    
    open var controlImageNamed: String = "" {
        didSet {
            if btControl == nil {
                return
            }
            
            btControl.setImage(UIImage(named: controlImageNamed), for: UIControl.State())
            btControl.backgroundColor = UIColor.clear
        }
    }
    
    open var editImageNamed: String = "" {
        didSet {
            if btEdit == nil {
                return
            }
            
            btEdit.setImage(UIImage(named: editImageNamed), for: UIControl.State())
            btEdit.backgroundColor = UIColor.clear
        }
    }
    
    open var deleteImageNamed: String = "" {
        didSet {
            if btDelete == nil {
                return
            }
            
            btDelete.setImage(UIImage(named: deleteImageNamed), for: UIControl.State())
            btDelete.backgroundColor = UIColor.clear
        }
    }
    
    /// 重新设置默认字体大小
    open func setDefaultFont() {
        shouldResizeAttribute = false
        font = UIFont.systemFont(ofSize: 18)
        shouldResizeAttribute = true
    }
    
    fileprivate func setupAttribute(_ text:NSString) {
        let tmpTransform = self.transform
        self.transform = CGAffineTransform.identity
        
        let attribute = [NSAttributedString.Key.font:font]
        let retSize = text.boundingRect(with: CGSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude), options:  [NSStringDrawingOptions.truncatesLastVisibleLine, .usesLineFragmentOrigin, .usesFontLeading], attributes: attribute, context: nil)
        
        let centerPoint = self.center
        var superFrame = self.frame
        superFrame.size.width = retSize.width + controlSize
        superFrame.size.height = retSize.height + controlSize
        self.frame = superFrame
        self.center = centerPoint
        subtitleLabel.frame = CGRect(x: controlSize / 2, y: controlSize / 2, width: retSize.size.width, height: retSize.size.height)
        if subtitleLabel.bounds.height != 0 {
            labelAspectRatio = subtitleLabel.bounds.width / subtitleLabel.bounds.height;
        } else {
            labelAspectRatio = 0;
        }
        
        subtitleLabel.text = text as String
        subtitleLabel.font = font
        let halfWidth = (self.bounds.width - controlSize) / 2
        let halfHeight = (self.bounds.height - controlSize) / 2
        sourceRadian = atan2(halfHeight, halfWidth)
        
        self.transform = tmpTransform
    }
    public override init(frame: CGRect) {
        var tmpFrame = frame
        if tmpFrame == CGRect.zero {
            tmpFrame = CGRect(x: 0, y: 0, width: controlSize * 2, height: controlSize * 2)
        }
        super.init(frame: tmpFrame)
        
        setup()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        setup()
    }
    
    fileprivate func setup() {
        
        let frame = self.frame
        
        subtitleLabel = UILabel(frame: CGRect(x: controlSize / 2, y: controlSize / 2, width: frame.width - controlSize, height: frame.height - controlSize))
        subtitleLabel.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        subtitleLabel.textAlignment = NSTextAlignment.center
        subtitleLabel.numberOfLines = 0
        
        subtitleLabel.font = font
        subtitleLabel.textColor = textColor
        subtitleLabel.layer.contentsScale = UIScreen.main.scale
        subtitleLabel.shadowColor = UIColor.gray
        subtitleLabel.shadowOffset = CGSize(width: 0.1, height: 0.1)
        subtitleLabel.isUserInteractionEnabled = true;
        
        addSubview(subtitleLabel)
        
        subtitleBorder = UIView(frame: CGRect(x: controlSize / 2 - borderWidth, y: controlSize / 2 - borderWidth, width: frame.width - controlSize + borderWidth * 2, height: frame.height - controlSize + borderWidth * 2))
        subtitleBorder.layer.shouldRasterize = true
        subtitleBorder.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        subtitleBorder.layer.borderWidth = borderWidth
        subtitleBorder.layer.borderColor = UIColor(red: 1, green: 0.4, blue: 0.218, alpha: 1).cgColor
        addSubview(subtitleBorder)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(subtitleTap(_:)))
        tapGesture.numberOfTapsRequired = 2
        subtitleBorder.addGestureRecognizer(tapGesture)
        
        btDelete = UIButton(type: .custom)
        btDelete.backgroundColor = UIColor.red
        btDelete.frame = CGRect(x: 0, y: 0, width: controlSize, height: controlSize)
        btDelete.layer.cornerRadius = btDelete.bounds.width / 2
        btDelete.autoresizingMask = [.flexibleBottomMargin, .flexibleRightMargin]
        btDelete.setImage(UIImage(named: deleteImageNamed), for: UIControl.State())
        addSubview(btDelete)
        btDelete.isHidden = true
        
        btDelete.addTarget(self, action: #selector(deleteAction(_:)), for: .touchUpInside)
        
        btEdit = UIButton(type: .custom)
        btEdit.backgroundColor = UIColor.blue
        btEdit.frame = CGRect(x: frame.width - controlSize, y: 0, width: controlSize, height: controlSize)
        btEdit.layer.cornerRadius = btEdit.bounds.width / 2
        btEdit.autoresizingMask = [.flexibleBottomMargin, .flexibleLeftMargin]
        btEdit.setImage(UIImage(named: controlImageNamed), for: UIControl.State())
        addSubview(btEdit)
        
        btEdit.addTarget(self, action: #selector(editAction(_:)), for: .touchUpInside)
        
        
        btControl = UIButton(type: .custom)
        btControl.backgroundColor = UIColor.orange
        btControl.frame = CGRect(x: frame.width - controlSize, y: frame.height - controlSize, width: controlSize, height: controlSize)
        btControl.layer.cornerRadius = btControl.bounds.width / 2
        btControl.autoresizingMask = [.flexibleTopMargin, .flexibleLeftMargin]
        btControl.setImage(UIImage(named: controlImageNamed), for: UIControl.State())
        addSubview(btControl)
        
        let panResizeGesture = UIPanGestureRecognizer(target: self, action: #selector(panResizeGesture(_:)))
        btControl.addGestureRecognizer(panResizeGesture)
        
        let halfWidth = (self.bounds.width - controlSize) / 2
        let halfHeight = (self.bounds.height - controlSize) / 2
        sourceRadian = atan2(halfHeight, halfWidth)
    }
    
    @objc func deleteAction(_ sender: UIButton) {
        
        self.delegate?.subtitleViewDidDelete(self)
    }
    
    @objc func editAction(_ sender: UIButton) {
        
        self.delegate?.subtitleViewDidEdit(self)
    }
    
    @objc func subtitleTap(_ recognizer: UITapGestureRecognizer) {
        
        self.delegate?.subtitleViewDidTap(self)
    }
    
    fileprivate var startPoint: CGPoint!
    fileprivate var startSize: CGSize!
    fileprivate var startFontSize: CGFloat!
    //
    fileprivate var sourceRadian: CGFloat = 0
    // 旋转缩放手势
    @objc func panResizeGesture(_ recognizer: UIPanGestureRecognizer) {
        
        if text == "" {
            return
        }
        
        switch recognizer.state {
        case .began:
            self.delegate?.subtitleViewDidResizeStart(self)
            
            startPoint = recognizer.location(in: self)
            startSize = self.subtitleLabel.bounds.size;
            startFontSize = self.subtitleLabel.font.pointSize;
            
            break
        case .changed, .possible:
            
            self.transform = CGAffineTransform.identity;
            
            /* Rotation */
            let radian = atan2(recognizer.location(in: self.superview!).y - self.center.y,
                recognizer.location(in: self.superview!).x - self.center.x)
            let deltaRadian = sourceRadian - radian;
            self.transform = CGAffineTransform(rotationAngle: -deltaRadian)
            
            // resizing
            let superPoint = recognizer.location(in: self.superview)
            var deltaWidth: CGFloat = 0.0
            
            let sqrtPoint = CGPoint(x: superPoint.x - self.center.x, y: superPoint.y - self.center.y)
            //
            deltaWidth = sqrt(sqrtPoint.x * sqrtPoint.x + sqrtPoint.y * sqrtPoint.y)
            
            let contentWidth: CGFloat = deltaWidth * cos(sourceRadian) * 2;
            let contentHeight: CGFloat = contentWidth / labelAspectRatio;
            
            let size: CGSize = CGSize(width: contentWidth + controlSize, height: contentHeight + controlSize)
            self.bounds = CGRect(x: self.bounds.origin.x, y: self.bounds.origin.y, width: size.width, height: size.height)
            
            let fontSize =  startFontSize * (1 + (self.subtitleLabel.bounds.size.width - startSize.width) / startSize.width)
            shouldResizeAttribute = false
            font = UIFont(name: font.fontName, size: fontSize)!
            shouldResizeAttribute = true
            subtitleLabel.font = font
            self.startPoint = recognizer.location(ofTouch: 0, in: self)
            
            checkRadian(false)
            
            self.delegate?.subtitleViewDidResizing(self)
            break;
        case .ended, .cancelled, .failed:
            checkRadian(true)
            
            self.delegate?.subtitleViewDidResizeEnd(self)
            break;
        @unknown default:
            break;
        }
    }
    
    // 5°内进行校准
    fileprivate let rotateTolerance: Double = 0.0872
    func checkRadian(_ isCancel: Bool) {
        var flag = false
        let rotate = rotatef()
        if rotate < 0 {
            
            if rotate > -rotateTolerance {
                if isCancel {
                    self.transform = CGAffineTransform.identity
                }
                flag = true
            } else if (rotate > -(Double.pi / 2) - rotateTolerance && rotate < -(Double.pi / 2) + rotateTolerance) {
                if isCancel {
                    self.transform = CGAffineTransform(rotationAngle: CGFloat(-(Double.pi / 2)))
                }
                flag = true
            } else if rotate < -Double.pi + rotateTolerance {
                if isCancel {
                    self.transform = CGAffineTransform(rotationAngle: CGFloat(-Double.pi))
                }
                flag = true
            }
        } else {
            
            if rotate < rotateTolerance {
                if isCancel {
                    self.transform = CGAffineTransform.identity
                }
                flag = true
            } else if rotate > (Double.pi / 2) - rotateTolerance && rotate < (Double.pi / 2) + rotateTolerance {
                if isCancel {
                    self.transform = CGAffineTransform(rotationAngle: CGFloat((Double.pi / 2)))
                }
                flag = true
            } else if rotate > Double.pi - rotateTolerance {
                if isCancel {
                    self.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi))
                }
                flag = true
            }
        }
        
        if flag {
            subtitleBorder.layer.borderColor = UIColor(red: 1, green: 0.4, blue: 0.218, alpha: 1).cgColor
        } else {
            subtitleBorder.layer.borderColor = UIColor.white.cgColor
        }
    }
    
    open func rotatef() ->Double {
        
        return (self.layer.value(forKeyPath: "transform.rotation.z") as! NSNumber).doubleValue
    }
    
    override open func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if let touch = touches.first {
            startMovePoint = touch.location(in: self.superview)
            
            self.delegate?.subtitleViewDidMoveStart(self)
        }
    }
    override open func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            
            let point = touch.location(in: self.superview)
            
            let deltaX = point.x - startMovePoint.x
            let deltaY = point.y - startMovePoint.y
            
            self.translation(deltaX: deltaX, deltaY: deltaY)
            startMovePoint = point
            self.delegate?.subtitleViewDidMoving(self)
        }
    }
    
    override open func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        // 回调
        self.delegate?.subtitleViewDidMoveEnd(self)
    }
    
    override open func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        
        self.delegate?.subtitleViewDidMoveEnd(self)
    }
    
    /// 平移偏移量
    open func translation(deltaX: CGFloat, deltaY: CGFloat) {
        
        var centerX = self.center.x + deltaX
        var centerY = self.center.y + deltaY
        if centerX < 0 {
            centerX = 0
        } else if centerX > self.superview!.bounds.width {
            centerX = self.superview!.bounds.width
        }
        
        if centerY < 0 {
            centerY = 0
        } else if centerY > self.superview!.bounds.height {
            centerY = self.superview!.bounds.height
        }
        
        self.center = CGPoint(x: centerX, y: centerY)
        
    }
    
    /** 指定位置 9个方向 */
    open func location(location: Int) {
        
        // 先切回正方向
        self.transform = CGAffineTransform.identity
        
        let contentWidth = self.bounds.width - controlSize
        let contentHeight = self.bounds.height - controlSize
        
        var centerPoint: CGPoint!
        switch location {
        case 0:
            centerPoint = CGPoint(x: contentWidth / 2, y: contentHeight / 2)
            break
        case 1:
            centerPoint = CGPoint(x: self.superview!.bounds.width / 2, y: contentHeight / 2)
            break
        case 2:
            centerPoint = CGPoint(x: (self.bounds.width + controlSize) / 2 + (self.superview!.bounds.width - self.bounds.width), y: contentHeight / 2)
            break
        case 3:
            centerPoint = CGPoint(x: contentWidth / 2, y: self.superview!.bounds.height / 2)
            break
        case 4:
            centerPoint = CGPoint(x: self.superview!.bounds.width / 2, y: self.superview!.bounds.height / 2)
            break
        case 5:
            centerPoint = CGPoint(x: (self.bounds.width + controlSize) / 2 + (self.superview!.bounds.width - self.bounds.width), y: self.superview!.bounds.height / 2)
            break
        case 6:
            centerPoint = CGPoint(x: contentWidth / 2, y: (self.bounds.height + controlSize) / 2 + (self.superview!.bounds.height - self.bounds.height))
            break
        case 7:
            centerPoint = CGPoint(x: self.superview!.bounds.width / 2, y: (self.bounds.height + controlSize) / 2 + (self.superview!.bounds.height - self.bounds.height))
            break
        case 8:
            centerPoint = CGPoint(x: (self.bounds.width + controlSize) / 2 + (self.superview!.bounds.width - self.bounds.width), y: (self.bounds.height + controlSize) / 2 + (self.superview!.bounds.height - self.bounds.height))
            break
        default:
            break
        }
        
        self.center = centerPoint
    }
    
}
