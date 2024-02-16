//
//  LYStickerView.swift
//  LYCompositionKit
//
//  Created by tony on 16/3/4.
//  Copyright © 2016年 chengkai. All rights reserved.
//

import UIKit

@objc public protocol LYStickerViewDelegate: NSObjectProtocol {
    
    func stickerViewDidMoveStart(_ stickerView: LYStickerView)
    
    func stickerViewDidMoving(_ stickerView: LYStickerView)
    
    func stickerViewDidMoveEnd(_ stickerView: LYStickerView)
    
    func stickerViewDidTap(_ stickerView:  LYStickerView)
    
    func stickerViewDidDelete(_ stickerView: LYStickerView)
    
    // 开始旋转缩放
    func stickerViewDidResizeStart(_ stickerView: LYStickerView)
    // 处于旋转和缩放中
    func stickerViewDidResizing(_ stickerView: LYStickerView)
    // 结束旋转缩放
    func stickerViewDidResizeEnd(_ stickerView: LYStickerView)
    
}

open class LYStickerView: UIView {
    
    open weak var delegate: LYStickerViewDelegate?
    
    fileprivate let controlSize:CGFloat = 30
    fileprivate var btDelete:UIButton!
    fileprivate var btControl:UIButton!
    
    fileprivate var borderWidth:CGFloat = 2
    fileprivate var stickerBorder: UIView!
    fileprivate var stickerImageView:UIImageView!
    
    fileprivate var startMovePoint:CGPoint!
    
    // 图片的原始尺寸
    fileprivate var originSize: CGSize!
    fileprivate var stickerAspectRatio:CGFloat!
    
    /// 贴图缩放比例 default = 1 按原始大小显示
    open var scale: CGFloat = 1
    open var stickerPath: String = "" {
        didSet {
            if stickerImageView == nil {
                return
            }
            
            guard let image = UIImage(contentsOfFile: stickerPath) else {
                return
            }
            
            let tmpTransform = self.transform
            self.transform = CGAffineTransform.identity
            
            originSize = image.size
            stickerAspectRatio = image.size.width / image.size.height
            
            let width = image.size.width * scale
            let height = width / stickerAspectRatio
            
            let imageSize = CGSize(width: width, height: height)
            
            let centerPoint = self.center
            var superFrame = self.frame
            superFrame.size.width = imageSize.width + controlSize
            superFrame.size.height = imageSize.height + controlSize
            self.frame = superFrame
            self.center = centerPoint
            
            let halfWidth = (self.bounds.width - controlSize) / 2
            let halfHeight = (self.bounds.height - controlSize) / 2
            sourceRadian = atan2(halfHeight, halfWidth)
            
            stickerImageView.image = image
            
            self.transform = tmpTransform
        }
    }
    
    open var stickerBorderColor: UIColor = UIColor(argb: "#ff6438")
    
    /** 是否打开删除按钮 default is false */
    open var deleteEnabled: Bool = false {
        didSet {
            btDelete.isHidden = !deleteEnabled
        }
    }
    
    open var stickerSize: CGSize {
        get {
            return CGSize(width: stickerImageView.frame.width, height: stickerImageView.frame.height)
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
    
    open var deleteImageNamed: String = "" {
        didSet {
            if btDelete == nil {
                return
            }
            
            btDelete.setImage(UIImage(named: deleteImageNamed), for: UIControl.State())
            btDelete.backgroundColor = UIColor.clear
        }
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
        
        stickerImageView = UIImageView(frame: CGRect(x: controlSize / 2, y: controlSize / 2, width: frame.width - controlSize, height: frame.height - controlSize))
        stickerImageView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        stickerImageView.contentMode = .scaleAspectFit
        stickerImageView.isUserInteractionEnabled=true;
        
        stickerImageView.image = UIImage(contentsOfFile: stickerPath)
        stickerAspectRatio = stickerImageView.bounds.size.width / stickerImageView.bounds.size.height
        
        addSubview(stickerImageView)
        
        stickerBorder = UIView(frame: CGRect(x: controlSize / 2 - borderWidth, y: controlSize / 2 - borderWidth, width: frame.width - controlSize + borderWidth * 2, height: frame.height - controlSize + borderWidth * 2))
        stickerBorder.layer.shouldRasterize = true
        stickerBorder.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        stickerBorder.layer.borderWidth = borderWidth
        stickerBorder.layer.borderColor = stickerBorderColor.cgColor
        addSubview(stickerBorder)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(subtitleTap(_:)))
        stickerBorder.addGestureRecognizer(tapGesture)
        
        btDelete = UIButton(type: .custom)
        btDelete.backgroundColor = UIColor.red
        btDelete.frame = CGRect(x: 0, y: 0, width: controlSize, height: controlSize)
        btDelete.layer.cornerRadius = btDelete.bounds.width / 2
        btDelete.autoresizingMask = [.flexibleBottomMargin, .flexibleRightMargin]
        btDelete.setImage(UIImage(named: deleteImageNamed), for: UIControl.State())
        addSubview(btDelete)
        btDelete.isHidden = true
        
        btDelete.addTarget(self, action: #selector(deleteAction(_:)), for: .touchUpInside)
        
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
        
        self.delegate?.stickerViewDidDelete(self)
    }
    
    @objc func subtitleTap(_ recognizer: UITapGestureRecognizer) {
        
        self.delegate?.stickerViewDidTap(self)
    }
    
    fileprivate var startPoint: CGPoint!
    //
    fileprivate var sourceRadian: CGFloat = 0
    // 旋转缩放手势
    @objc func panResizeGesture(_ recognizer: UIPanGestureRecognizer) {
        
        switch recognizer.state {
        case .began:
            self.delegate?.stickerViewDidResizeStart(self)
            
            startPoint = recognizer.location(in: self)
            break
        case .changed, .possible:
            self.transform = CGAffineTransform.identity;
            
            /* Rotation */
            let radian = atan2(recognizer.location(in: self.superview!).y - self.center.y,
                recognizer.location(in: self.superview!).x - self.center.x)
            let deltaRadian = sourceRadian - radian;
            self.transform = CGAffineTransform(rotationAngle: -deltaRadian);
            
            // resizing
            let superPoint = recognizer.location(in: self.superview)
            var deltaWidth: CGFloat = 0.0
            
            let sqrtPoint = CGPoint(x: superPoint.x - self.center.x, y: superPoint.y - self.center.y)
            //
            deltaWidth = sqrt(sqrtPoint.x * sqrtPoint.x + sqrtPoint.y * sqrtPoint.y)
            
            let contentWidth: CGFloat = deltaWidth * cos(sourceRadian) * 2;
            let contentHeight: CGFloat = contentWidth / stickerAspectRatio;
            
            scale = contentWidth / originSize.width
            
            let size: CGSize=CGSize(width: contentWidth + controlSize, height: contentHeight + controlSize)
            self.bounds = CGRect(x: self.bounds.origin.x, y: self.bounds.origin.y, width: size.width, height: size.height)
            
            self.startPoint = recognizer.location(ofTouch: 0, in: self)
            
            checkRadian(false)
            
            self.delegate?.stickerViewDidResizing(self)
            break;
        case .ended, .cancelled, .failed:
            checkRadian(true)
            
            self.delegate?.stickerViewDidResizeEnd(self)
            break;
        @unknown default:
            break;
        }
    }
    
    fileprivate let rotateTolerance: Double = 0.05
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
            stickerBorder.layer.borderColor = stickerBorderColor.cgColor
        } else {
            stickerBorder.layer.borderColor = UIColor.white.cgColor
        }
    }
    
    open func rotatef() ->Double {
        
        return (self.layer.value(forKeyPath: "transform.rotation.z") as! NSNumber).doubleValue
    }
    
    override open func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if let touch = touches.first {
            startMovePoint = touch.location(in: self.superview)
            
            self.delegate?.stickerViewDidMoveStart(self)
        }
    }
    override open func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            
            let point = touch.location(in: self.superview)
            
            let deltaX = point.x - startMovePoint.x
            let deltaY = point.y - startMovePoint.y
            
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
            startMovePoint = point
            self.delegate?.stickerViewDidMoving(self)
        }
    }
    
    override open func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        self.delegate?.stickerViewDidMoveEnd(self)
    }
    
    override open func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        self.delegate?.stickerViewDidMoveEnd(self)
    }
    
}


