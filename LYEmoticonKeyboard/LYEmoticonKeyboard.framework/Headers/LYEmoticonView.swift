//
//  LYEmoticonView.swift
//  LYEmoticonKeyboard
//
//  Created by tony on 16/2/24.
//  Copyright © 2016年 tony. All rights reserved.
//

import UIKit

protocol LYEmoticonViewDelegate: NSObjectProtocol {
    
    /// 选中某个表情
    func emoticonView(_ emoticonView: LYEmoticonView, didSelectEmoticon emoticon: LYEmoticon)
    
}

// 显示表情的view视图
open class LYEmoticonView: UIView {

    open var row: Int = 1
    open var column: Int = 1
    
    open var panelHeight: CGFloat = 0
    
    /// 一定是正方形
    fileprivate var emoticonSize: CGFloat = 0
    fileprivate let margin: UIEdgeInsets = UIEdgeInsets.init(top: 10, left: 10, bottom: 10, right: 10)
    

    fileprivate var itemWidth: CGFloat {
        get {
            return (self.frame.width - margin.left - margin.right) / CGFloat(column)
        }
    }
    
    fileprivate var itemHeight: CGFloat {
        get {
            return (self.frame.height - margin.top - margin.bottom) / CGFloat(row)
        }
    }
    
    fileprivate var touchedIndex: Int?
    fileprivate var previewView: LYEmoticonPreviewView = LYEmoticonPreviewView(frame: CGRect(x: 0, y: 0, width: 128, height: 180))
    
    var emoticons: [LYEmoticon]? {
        didSet {
            self.setNeedsDisplay()
        }
    }
    
    weak var delegate: LYEmoticonViewDelegate?
    
    public init(frame: CGRect, size: CGFloat) {
        self.emoticonSize = size
        super.init(frame: frame)
        
        self.backgroundColor = UIColor.clear
        self.addSubview(previewView)
        previewView.isHidden = true
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapAction(_:)))
        self.addGestureRecognizer(tapGesture)

        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(longPressAction(_:)))
        longPressGesture.minimumPressDuration = 0.2
        self.addGestureRecognizer(longPressGesture)
    }

    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// 绘制表情
    func drawImage(_ emoticon: LYEmoticon, index: Int) {
        
        guard let path = emoticon.path else {
            return
        }
        
        guard let image = UIImage(contentsOfFile: path) else {
            return
        }
        
        let leftMargin = (itemWidth - emoticonSize) / 2.0
        var topMargin = (itemWidth - emoticonSize) / 2.0
        
        if panelHeight != 0 {
            topMargin = (panelHeight / 3 - emoticonSize) / 2.0
        }
        
        let x = margin.left + itemWidth * CGFloat(index % column) + leftMargin
        let y = margin.top + itemHeight * CGFloat(index / column) + topMargin
        
        var width = emoticonSize
        var height = emoticonSize
        if emoticon.size != CGSize.zero {
            width = emoticon.size.width
            height = emoticon.size.height
        }else {
            if image.size.width < image.size.height {
                let ratio = image.size.height / emoticonSize
                width = image.size.width / ratio
            }else {
                let ratio = image.size.width / emoticonSize
                height = image.size.height / ratio
            }
            emoticon.size = CGSize(width: width, height: height)
        }

        let rect = CGRect(x: x + (emoticonSize - width) / 2, y: y + (emoticonSize - height) / 2, width: width, height: height)
        
        // 这里要计算出绘制的起点
        image.draw(in: rect)
    }
    
    override open func draw(_ rect: CGRect) {
        
        guard let emoticons = self.emoticons else {
            return
        }
        
        var index: Int = 0
        for emoticon in emoticons {
            drawImage(emoticon, index: index)
            
            index += 1
            if index >= row * column {
                break
            }
        }
        
    }
    
    /// 单击事件
    @objc func tapAction(_ gesture: UITapGestureRecognizer) {
        guard let emoticons = self.emoticons else {
            return
        }
        
        if let index = indexWithLocation(gesture.location(in: self)) {
            
            let emoticon = emoticons[index]
            self.delegate?.emoticonView(self, didSelectEmoticon: emoticon)
        }
    }
    
    // 长按预览表情
    @objc func longPressAction(_ gesture: UILongPressGestureRecognizer) {
        guard let emoticons = self.emoticons else {
            return
        }
        
        switch gesture.state {
        case .began:
            if let index = indexWithLocation(gesture.location(in: self)) {
                
                CATransaction.begin()
                CATransaction.setValue(kCFBooleanTrue, forKey: kCATransactionDisableActions)
                updateWithIndex(index)
                CATransaction.commit()
            }
            break
        case .changed:
            if let index = indexWithLocation(gesture.location(in: self)) {
                
                updateWithIndex(index)
            } else {
                touchedIndex = nil
                previewView.isHidden = true
            }
            break
        default:
            if let index = touchedIndex {
                let emoticon = emoticons[index]
                self.delegate?.emoticonView(self, didSelectEmoticon: emoticon)
            }
            
            touchedIndex = nil
            previewView.isHidden = true
            break
        }
    }
    
    /// 计算触摸点的表情索引
    func indexWithLocation(_ location: CGPoint) ->Int? {
        if location.x < margin.left || location.x > (self.frame.width - margin.right) || location.y < margin.top || location.y > (self.frame.height - margin.bottom) {
            return nil
        } else {
            let columnTmp = Int((location.x - margin.left) / itemWidth)
            let rowTmp = Int((location.y - margin.top) / itemHeight)
            return rowTmp * column + columnTmp
        }
    }
    
    /// 更新预览视图
    func updateWithIndex(_ index: Int) {
        guard let emoticons = self.emoticons else {
            return
        }
        
        if index > emoticons.count - 1 {
            return
        }
        
        touchedIndex = index
        if previewView.isHidden == true {
            previewView.isHidden = false
        }
        // 预览x = left边缘 + 触摸的item的x + (item宽 - 预览宽)/2.0
        let previewX = margin.left + itemWidth * CGFloat(index % column) + (itemWidth - previewView.frame.width) / 2.0
        // 预览y = top边缘 + 触摸的item的y + (item高 - 表情高)/2.0 + 表情高 - 预览高
        let previewY = margin.top + CGFloat(index / column) * itemHeight + (itemHeight - emoticonSize) / 2.0 + emoticonSize - previewView.frame.height
        previewView.emoticon = emoticons[index]
        previewView.frame = CGRect(x: previewX, y: previewY, width: previewView.frame.width, height: previewView.frame.height)
        
    }

}

/// 表情预览视图
class LYEmoticonPreviewView: UIView {
    
    let backgroundImage = UIImage(named: "img_emoticon_preview")
    
    var emoticon: LYEmoticon? {
        didSet {
            self.setNeedsDisplay()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.clear
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        backgroundImage?.draw(in: self.bounds)
        
        if let path = emoticon?.path {
            if let image = UIImage(contentsOfFile: path){
                
                let size = self.frame.width - 12 * 2
                if emoticon!.previewSize != CGSize.zero {
                    let width = emoticon!.previewSize.width
                    let height = emoticon!.previewSize.height
                    let rect = CGRect(x: 12 + (size - width) / 2, y: 4 + (size - height) / 2, width: width, height: height)
                    image.draw(in: rect)
                    return
                }
                
                var width = size
                var height = size
                
                if image.size.width < image.size.height {
                    let ratio = image.size.height / width
                    width = image.size.width / ratio
                }else {
                    let ratio = image.size.width / width
                    height = image.size.height / ratio
                }
                emoticon?.previewSize = CGSize(width: width, height: height)
                
                let rect = CGRect(x: 12 + (size - width) / 2, y: 4 + (size - height) / 2, width: width, height: height)
                image.draw(in: rect)
            }
        }
        
        // 如果是emoji表情需要作特别处理
//        let attributes = [NSFontAttributeName: UIFont.systemFontOfSize(38)]
//        let emojiRect = (emoji as NSString).boundingRectWithSize(CGSizeMake(CGFloat.max, CGFloat.max), options: [NSStringDrawingOptions.UsesLineFragmentOrigin, NSStringDrawingOptions.UsesFontLeading], attributes: attributes, context: nil)
//        let emojiWidth = emojiRect.width
//        let emojiHeight = emojiRect.height
//        let emojiX = (self.width - emojiWidth) / 2.0
//        //表情是emoji
//        (emoji as NSString).drawInRect(CGRectMake(emojiX, 2, emojiWidth, emojiHeight), withAttributes: attributes)
    }
    
}
