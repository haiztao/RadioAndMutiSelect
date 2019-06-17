//
//  Category.swift
//  Sleep
//
//  Created by 赖灵伟 on 15/10/6.
//  Copyright © 2015年 深圳创世易明科技有限公司. All rights reserved.
//

import Foundation
import UIKit


extension UIView {
    /**UIView转UIImage*/
    func imageFromView() -> UIImage {
        UIGraphicsBeginImageContextWithOptions(bounds.size, true, 1.0)
        layer.render(in: UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image!
    }
}



extension UIWindow {
    /**UIWindow转UIImage*/
    func imageFromWindow() -> UIImage {
        UIGraphicsBeginImageContextWithOptions(bounds.size, true, 1.0)
        layer.render(in: UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image!
    }
}


extension Data {
    
    /**把16进制NSData转为字符串,如 <000e0b046f75> 转为 “000e0b046f75” */
    func toHexString() -> String {
        var hexStr: String = ""
        for i in 2..<count {
            var temp: UInt8 = 0x00
            (self as NSData).getBytes(&temp, range: NSRange(location: i, length: 1))
            var string = NSString(format: "%x", temp)
            if string.length == 1 {
                string = "0" + (string as String) as NSString
            }
            hexStr = hexStr + (string as String)
        }
        return hexStr
    }
    
}

extension NSString {
    
    /**把字符串转为16进制NSData,如 “000e0b046f75” 转为 <000e0b046f75>*/
    func toHexBytesData() -> Data {
        let nsString = self as NSString
        let data = NSMutableData()
        var idx: Int = 0
        for i in 0..<nsString.length {
            idx = 2 * i
            if idx + 2 > nsString.length {
                break
            }
            let range = NSMakeRange(idx, 2)
            let hexStr = nsString.substring(with: range)
            
            let scanner = Scanner(string: hexStr)
            
            var intValue: UInt32 = 0
            scanner.scanHexInt32(&intValue)
            data.append(&intValue, length: 1)
        }
        
        return data as Data
    }
    
}


extension String {

    /**获取汉字的拼音*/
    func fetchPinYin(isreplacingOccurrences:Bool = false) -> String {
        let ms = CFStringCreateMutableCopy(nil, 0, "\(self)" as CFString)
        CFStringTransform(ms, nil, kCFStringTransformMandarinLatin, false)      // 带声调拼音
        CFStringTransform(ms, nil, kCFStringTransformStripDiacritics, false)    // 去声调拼音
 
        var string = ""
        if isreplacingOccurrences == true {
            string = ms! as String
           return String(describing: string.replacingOccurrences(of: " ", with: ""))
        }else{
            return String(describing: ms)
        }
    }
}

extension UIImage {
    
    /**在原图片上截取一定区域的图片*/
    func cropImageWithRect(_ rect: CGRect) -> UIImage {
        
        var rectTransform: CGAffineTransform
        switch imageOrientation {
        case .left:
            rectTransform = CGAffineTransform(rotationAngle: CGFloat(Double.pi / 2)).translatedBy(x: 0, y: -size.height)
        case .right:
            rectTransform = CGAffineTransform(rotationAngle: CGFloat(-Double.pi / 2)).translatedBy(x: -size.width, y: 0)
        case .down:
            rectTransform = CGAffineTransform(rotationAngle: CGFloat(-Double.pi)).translatedBy(x: -size.width, y: -size.height)
        default:
            rectTransform = CGAffineTransform.identity
        }
        rectTransform = rectTransform.scaledBy(x: scale, y: scale)
        
        let imageRef = cgImage!.cropping(to: rect.applying(rectTransform))
        
        return UIImage(cgImage: imageRef!, scale: scale, orientation: imageOrientation)
    }
    
    
    /**图片压缩成指定大小*/
    func scaleToSize(_ size: CGSize) -> UIImage {
        
        UIGraphicsBeginImageContext(size)
        draw(in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        let scaleImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return scaleImage!
    }
    
}

extension UILabel {
    //缩放字体
    func  fontsizeZoomInTo(_ originSize:CGFloat, Scale:CGFloat){
//        let size = self.font.pointSize
        self.font = UIFont.systemFont(ofSize: originSize * Scale)
    }
    //label顶部对齐
    func AlignToTop(){

        let sizeOrigin = self.frame.size
        let sizeAfter = CGSize(width: sizeOrigin.width, height: 10000)
        if self.text != nil {
            let size1 = (self.text! + "\n" as NSString).boundingRect(with: sizeAfter,
                                                                      options: NSStringDrawingOptions.usesLineFragmentOrigin,
                                                                      attributes: [NSAttributedString.Key.font: self.font],
                                                                      context: nil)
            let rect = self.frame
            self.frame = CGRect(x: rect.origin.x, y: rect.origin.y, width: rect.size.width, height: size1.height)
        }
        
      }

}

// MARK: - UIColor
extension UIColor {
    
    //随机颜色
    class func randomColor()->UIColor{
        let red = CGFloat(arc4random_uniform(255))
        let green = CGFloat(arc4random_uniform(255))
        let blue = CGFloat(arc4random_uniform(255))
        return UIColor(red: red/255, green: green/255, blue: blue/255, alpha: 1.0)
    }
    /**
     16进制转UIColor
     
     - parameter hex: 16进制颜色字符串
     
     - returns: 转换后的颜色
     */
    class func ColorHex(_ hex: String) -> UIColor {
        return proceesHex(hex, alpha: 1.0)
    }
    
    /**
     16进制转UIColor，
     
     - parameter hex:   16进制颜色字符串
     - parameter alpha: 透明度
     
     - returns: 转换后的颜色
     */
    class func ColorHexWithAlpha(_ hex: String, alpha: CGFloat) -> UIColor {
        return proceesHex(hex, alpha: alpha)
    }
}

// MARK: - 主要逻辑
private func proceesHex(_ hex: String, alpha: CGFloat) -> UIColor{
    /** 如果传入的字符串为空 */
    if hex.isEmpty {
        return UIColor.clear
    }
    /** 传进来的值。 去掉了可能包含的空格、特殊字符， 并且全部转换为大写 */
    let set = CharacterSet.whitespaces
    //var hHex = hex.stringByTrimmingCharactersInSet(set).uppercased()
    var hHex = hex.trimmingCharacters(in: set).uppercased()
    /** 如果处理过后的字符串少于6位 */
    if hHex.count < 6 {
        return UIColor.clear
    }
    
    /** 开头是用0x开始的 */
    if hHex.hasPrefix("0X") {
        hHex = (hHex as NSString).substring(from: 2)
    }
    /** 开头是以＃开头的 */
    if hHex.hasPrefix("#") {
        hHex = (hHex as NSString).substring(from: 1)
    }
    /** 开头是以＃＃开始的 */
    if hHex.hasPrefix("##") {
        hHex = (hHex as NSString).substring(from: 2)
    }
    
    /** 截取出来的有效长度是6位， 所以不是6位的直接返回 */
    if hHex.count != 6 {
        return UIColor.clear
    }
    
    /** R G B */
    var range = NSMakeRange(0, 2)
    
    /** R */
    let rHex = (hHex as NSString).substring(with: range)
    
    /** G */
    range.location = 2
    let gHex = (hHex as NSString).substring(with: range)
    
    /** B */
    range.location = 4
    let bHex = (hHex as NSString).substring(with: range)
    
    /** 类型转换 */
    var r:CUnsignedInt = 0, g:CUnsignedInt = 0, b:CUnsignedInt = 0;
    
    Scanner(string: rHex).scanHexInt32(&r)
    Scanner(string: gHex).scanHexInt32(&g)
    Scanner(string: bHex).scanHexInt32(&b)
    
    return UIColor(red: CGFloat(r) / 255.0, green: CGFloat(g) / 255.0, blue: CGFloat(b) / 255.0, alpha: alpha)
}






