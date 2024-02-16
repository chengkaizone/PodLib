//
//  LYSliderView.swift
//  LineVideo
//
//  Created by tony on 16/3/4.
//  Copyright © 2016年 chengkaizone. All rights reserved.
//

import UIKit

@objc protocol LYSliderViewDelegate: NSObjectProtocol {
    
    /// dX拖动左边滑块的偏移量 sliderFrame为此时在滑动视图内的frame
    func sliderView(_ sliderView: LYSliderView, didSlideLeftSliderFrame sliderFrame: CGRect, withDelta dX: CGFloat);
    
    /// delta拖动右边边滑块的偏移量 sliderFrame为此时在滑动视图内的frame
    func sliderView(_ sliderView: LYSliderView, didSlideRightSliderFrame sliderFrame: CGRect, withDelta dX: CGFloat);
    
    /// 滑动结束
    func sliderViewDidFinishSliding(_ sliderView: LYSliderView);
    
}

// 滑块状态
private enum LYSliderStatus {
    case normal, leftHighlight, rightHighlight
    
    func backgroundColor() ->UIColor {
        
        return UIColor.clear;
    }
    
    func leftSliderColor() ->UIColor {
        switch self {
        case .normal:fallthrough;
        case .rightHighlight:
            return UIColor(white: 0, alpha: 0.5);
        case .leftHighlight:
            return UIColor.red;
        }
    }
    
    func rightSliderColor() ->UIColor {
        switch self {
        case .normal:fallthrough;
        case .leftHighlight:
            return UIColor(white: 0, alpha: 0.5);
        case .rightHighlight:
            return UIColor.red;
        }
    }
    
}

/// 时间区域修剪
class LYSliderView: UIView {
    
    static var sliderWidth: CGFloat = 20;
    
    // 两滑块之间的最小距离 --- 这里由计算最短的秒数计算出最小的距离
    var minimumSpace: CGFloat = 5;
    fileprivate var rangeRect: CGRect!;
    
    // 可以记录状态
    var leftSlider: UIButton!;
    var rightSlider: UIButton!;
    
    // 上下边框线
    var edgeUpLine: UIImageView!
    var edgeDownLine: UIImageView!
    var edgeLineHeight: CGFloat = 2
    // 上下边的颜色
    lazy var edgeColor:UIColor = UIColor(red: 1, green: 0.78, blue: 0, alpha: 1)
    
    fileprivate var beginPositionOfLeftPan: CGFloat = 0;
    fileprivate var beginPositionOfRightPan: CGFloat = 0;
    
    weak var delegate:LYSliderViewDelegate?;
    
    // 是否设置的滑块
    fileprivate(set) var isSetControl:Bool = false
    
    fileprivate var status: LYSliderStatus! = .normal {
        didSet {
            guard let status = status else {
                return;
            }
            
            backgroundColor = status.backgroundColor();
            if isSetControl == false {
                leftSlider.backgroundColor = status.leftSliderColor()
                rightSlider.backgroundColor = status.rightSliderColor()
            } else {
                leftSlider.backgroundColor = UIColor.clear
                rightSlider.backgroundColor = UIColor.clear
            }
            
        }
    }
    
    //MARK: - init
    fileprivate override init(frame: CGRect) {
        super.init(frame: frame);
        
        self.setup();
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder);
        
        self.setup();
    }
    
    init(frame: CGRect, rangeRect: CGRect, delegate: LYSliderViewDelegate?) {
        super.init(frame: frame);
        self.delegate = delegate;
        self.rangeRect = rangeRect;
        
        self.setup();
    }
    
    /// 初始化视图
    fileprivate func setup() {
        self.isUserInteractionEnabled = true;
        
        self.edgeUpLine = UIImageView()
        edgeUpLine.frame = CGRect(x: LYSliderView.sliderWidth, y: 0, width: self.bounds.width - LYSliderView.sliderWidth * 2, height: edgeLineHeight)
        edgeUpLine.backgroundColor = edgeColor
        edgeUpLine.autoresizingMask = .flexibleBottomMargin
        addSubview(edgeUpLine)
        
        self.edgeDownLine = UIImageView()
        edgeDownLine.frame = CGRect(x: LYSliderView.sliderWidth, y: self.bounds.height - edgeLineHeight, width: self.bounds.width - LYSliderView.sliderWidth * 2, height: edgeLineHeight)
        edgeDownLine.backgroundColor = edgeColor
        edgeDownLine.autoresizingMask = .flexibleTopMargin
        addSubview(edgeDownLine)
        
        self.leftSlider = UIButton(type: .custom);
        leftSlider.frame = CGRect(x: 0, y: 0, width: LYSliderView.sliderWidth, height: self.bounds.height);
        leftSlider.autoresizingMask = .flexibleRightMargin;
        leftSlider.isUserInteractionEnabled = true;
        self.addSubview(leftSlider);
        
        self.rightSlider = UIButton(type: .custom);
        rightSlider.frame = CGRect(x: self.bounds.width - LYSliderView.sliderWidth, y: 0, width: LYSliderView.sliderWidth, height: self.bounds.height);
        rightSlider.autoresizingMask = .flexibleLeftMargin;
        rightSlider.isUserInteractionEnabled = true;
        rightSlider.backgroundColor = UIColor.clear
        self.addSubview(rightSlider);
        
        let leftGesture = UILongPressGestureRecognizer(target: self, action: #selector(leftSliderPanned(_:)));
        leftGesture.minimumPressDuration = 0;
        leftSlider.addGestureRecognizer(leftGesture);
        
        let rightGesture = UILongPressGestureRecognizer(target: self, action: #selector(rightSliderPanned(_:)));
        rightGesture.minimumPressDuration = 0;
        rightSlider.addGestureRecognizer(rightGesture);
        
        self.status = .normal
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        edgeUpLine.frame = CGRect(x: LYSliderView.sliderWidth, y: 0, width: self.bounds.width - LYSliderView.sliderWidth * 2, height: edgeLineHeight)
        edgeDownLine.frame = CGRect(x: LYSliderView.sliderWidth, y: self.bounds.height - edgeLineHeight, width: self.bounds.width - LYSliderView.sliderWidth * 2, height: edgeLineHeight)
    }
    
    func setSliderImage(_ slider: UIButton, imageName: String?, hightlightedName: String?) {
        if let name = imageName {
            slider.setBackgroundImage(UIImage(named: name), for: UIControl.State())
            isSetControl = true
            self.status = .normal
        }
        
        if let name = hightlightedName {
            slider.setBackgroundImage(UIImage(named: name), for: .highlighted)
            slider.setBackgroundImage(UIImage(named: name), for: .selected)
        }
    }
    
    //MARK: - gesture
    @objc internal func leftSliderPanned(_ recognizer: UILongPressGestureRecognizer) {
        rightSlider.isSelected = false
        leftSlider.isSelected = true
        
        let positionX = recognizer.location(in: leftSlider).x;
        
        switch recognizer.state {
        case .began:
            beginPositionOfLeftPan = positionX;
            fallthrough;
        case .possible, .changed:
            status = .leftHighlight;
            break;
        case .cancelled, .ended, .failed:
            status = .normal;
            self.delegate?.sliderViewDidFinishSliding(self);
            return;
        @unknown default:
            break;
        }
        
        var delta = positionX - beginPositionOfLeftPan;
        let maxDelta = rightSlider.frame.minX - leftSlider.frame.maxX - minimumSpace;
        if delta > maxDelta {
            delta = maxDelta;
        }
        
        let minDelta = rangeRect.minX - LYSliderView.sliderWidth - frame.minX;
        if delta < minDelta {
            delta = minDelta;
        }
        
        if delta != 0 {
            self.delegate?.sliderView(self, didSlideLeftSliderFrame: leftSlider.frame, withDelta: delta);
        }
        
    }
    
    @objc internal func rightSliderPanned(_ recognizer: UILongPressGestureRecognizer) {
        rightSlider.isSelected = true
        leftSlider.isSelected = false
        
        let positionX = recognizer.location(in: rightSlider).x;
        
        switch recognizer.state {
        case .began:
            beginPositionOfRightPan = positionX;
            fallthrough;
        case .possible, .changed:
            status = .rightHighlight;
            break;
        case .cancelled, .ended, .failed:
            status = .normal;
            self.delegate?.sliderViewDidFinishSliding(self);
            return;
        @unknown default:
            break;
        }
        
        var delta = positionX - beginPositionOfRightPan;
        let minDelta = leftSlider.frame.maxX - rightSlider.frame.minX + minimumSpace;
        if delta < minDelta {
            delta = minDelta;
        }
        
        let maxDelta = rangeRect.width + LYSliderView.sliderWidth - frame.maxX;
        if delta > maxDelta {
            delta = maxDelta;
        }
        
        if delta != 0 {
            self.delegate?.sliderView(self, didSlideRightSliderFrame: rightSlider.frame, withDelta: delta);
        }
        
    }
    
}
