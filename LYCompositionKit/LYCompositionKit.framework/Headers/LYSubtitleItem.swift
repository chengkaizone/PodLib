//
//  LYSubtitleItem.swift
//  LYCompositionKit
//
//  Created by tony on 16/3/4.
//  Copyright © 2016年 chengkai. All rights reserved.
//

import UIKit

/** 字幕覆盖物 */
open class LYSubtitleItem: LYTitleItem {
    
    /** 字符串 */
    open var text:String;
    /** 字体名 */
    open var fontName:String;
    /**
     * 字体大小
     * 这一步不太好解决;
     * 旋转缩放得到的大小如何映射为渲染的字体大小
     */
    open var fontSize:CGFloat;
    /**
     *  字体大小缩放比例,不缩放就是预览
     *  缩放是渲染时使用
     */
    open var fontScale:CGFloat;
    /** 字体颜色 */
    open var fontColor:UIColor;
    
    // 字体背景色
    open var fontBackgroundColor: UIColor
    
    /** 主要构造器 */
    public init(text: String, fontName: String, fontSize: CGFloat, fontScale:CGFloat, fontColor: UIColor, fontBackgroundColor: UIColor, animated: Bool) {
        
        self.text = text;
        self.fontName = fontName;
        self.fontScale = fontScale;
        self.fontSize = fontSize;
        self.fontColor = fontColor;
        self.fontBackgroundColor = fontBackgroundColor
        
        super.init();
        
        self.animated = animated
    }
    
    public init(text: String) {
        
        self.text = text;
        let font = UIFont.boldSystemFont(ofSize: 18)
        self.fontName = font.fontName
        self.fontSize = font.pointSize
        self.fontScale = 1;
        self.fontColor = UIColor.white;
        self.fontBackgroundColor = UIColor.clear
        
        super.init();
    }
    
    public required convenience init() {
        
        self.init(text: "");
    }
    
    /**
     * 创建layer图层
     * size 预览或者渲染大小
     */
    open override func buildLayer(_ size:CGSize, isRender:Bool) ->CALayer {
        
        // 创建含文本和图片的标题图层
        let parentLayer = CALayer();
        
        // 这样创建 position会在中心位置
        parentLayer.frame = CGRect(x: 0, y: 0, width: size.width, height: size.height);
        
        parentLayer.opacity = 0.0;
        
        let textLayer = self.makeTextLayer(size, isRender: isRender);
        parentLayer.addSublayer(textLayer);
        
        textLayer.setAffineTransform(self.transform)
        
        let position = CGPoint(x: self.ratioRect.origin.x * size.width, y: self.ratioRect.origin.y * size.height);
        
        textLayer.position = position
        
        NSLog("Subtitle 是否有动画：\(animated)")
        // 淡入淡出 --- 字幕只用这个动画就基本满足要求了
        let fadeInFadeOutAnimation = self.makeFadeInFadeOutAnimation();
        parentLayer.add(fadeInFadeOutAnimation, forKey: nil);
        
        return parentLayer;
    }
    
    /**
     * 创建文本图层
     * 这里还有些问题
     */
    open func makeTextLayer(_ size:CGSize, isRender:Bool) ->CALayer {
        
        var fontSize = self.fontSize;
        if isRender {
            fontSize = self.fontSize * self.fontScale;
        }
        var font = UIFont(name: self.fontName, size: fontSize)
        if font == nil {
            font = UIFont.systemFont(ofSize: fontSize)
        }
        //这里使用富文本来设置字体的颜色
        var attrs: [NSAttributedString.Key:Any] = [NSAttributedString.Key.font: font!, NSAttributedString.Key.foregroundColor: self.fontColor.cgColor];
        
        let string = NSMutableAttributedString(string: self.text, attributes: attrs);
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 5
        string.addAttribute(NSAttributedString.Key.paragraphStyle, value: paragraphStyle, range: NSMakeRange(0, self.text.count))
        
        attrs[NSAttributedString.Key.paragraphStyle] = paragraphStyle
        let textSize = (self.text as NSString).size(withAttributes: attrs);
        
        // anchorPoint 为0.5 应用旋转才正常
        let textLayer = CATextLayer();
        textLayer.isWrapped = true;
        
        textLayer.backgroundColor = self.fontBackgroundColor.cgColor
        textLayer.string = string;
        
        textLayer.shadowColor = UIColor.black.cgColor
        textLayer.shadowOffset = CGSize(width: 0.3, height: 0.3)
        
        // anchorPoint, position 都会是中心点
        textLayer.frame = CGRect(x: 0, y: 0, width: textSize.width, height: textSize.height);
        // 解决字体模糊 retina
        textLayer.contentsScale = UIScreen.main.scale
        // 文本不居中??? 系统原因
        textLayer.alignmentMode = CATextLayerAlignmentMode.center
        
        return textLayer;
    }
    
    // NSCoding 协议
    public required init?(coder aDecoder: NSCoder) {
        
        self.text = aDecoder.decodeObject(forKey: "text") as! String;
        self.fontName = aDecoder.decodeObject(forKey: "fontName") as! String;
        self.fontSize = CGFloat(aDecoder.decodeDouble(forKey: "fontSize"));
        self.fontScale = CGFloat(aDecoder.decodeDouble(forKey: "fontScale"));
        self.fontColor = aDecoder.decodeObject(forKey: "fontColor") as! UIColor;
        
        if let fontBackgroundColor = aDecoder.decodeObject(forKey: "fontBackgroundColor") as? UIColor {
            self.fontBackgroundColor = fontBackgroundColor
        } else {
            self.fontBackgroundColor = UIColor.clear
        }
        
        super.init(coder: aDecoder);
    }
    
    // NSCoding 协议
    open override func encode(with aCoder: NSCoder) {
        
        aCoder.encode(self.text, forKey: "text");
        aCoder.encode(self.fontName, forKey: "fontName");
        aCoder.encode(Double(self.fontSize), forKey: "fontSize");
        aCoder.encode(Double(self.fontScale), forKey: "fontScale");
        aCoder.encode(self.fontColor, forKey: "fontColor");
        aCoder.encode(self.fontBackgroundColor, forKey: "fontBackgroundColor")
        
        super.encode(with: aCoder);
    }
    
    override func copyAttrs(_ timelineItem: LYTimelineItem) {
        super.copyAttrs(timelineItem)
        
        let subtitleItem = timelineItem as! LYSubtitleItem;
        
        subtitleItem.text = self.text;
        subtitleItem.fontName = self.fontName;
        subtitleItem.fontSize = self.fontSize;
        subtitleItem.fontScale = self.fontScale;
        subtitleItem.fontColor = self.fontColor.copy() as! UIColor
        subtitleItem.fontBackgroundColor = self.fontBackgroundColor.copy() as! UIColor
    }
    
}
