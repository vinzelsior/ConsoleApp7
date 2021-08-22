//
//  ImageConversion.swift
//  ConsoleApp7_Now_Streaming
//
//  Created by Cedric Zwahlen on 30.07.21.
//

import Foundation
import Cocoa

class StreamToString {
    
    struct TextPixel {
        let range: NSRange
        let color: NSColor
    }
    
    enum LuminanceType: Int {
        case horizontal, vertical, shaded, letters
    }
    
    
    private var currentLuminanceType: LuminanceType
    var luminanceType: LuminanceType {
        get {
            currentLuminanceType
        }
        set {
            currentLuminanceType = newValue
            luminanceValues.removeAll()
            for c in luminanceTypes[newValue.rawValue] { luminanceValues.append(c) }
            
            if range <= luminanceValues.count { range = 255 }
            
            divisor = 255 / (luminanceValues.count - 1)
            factor = 255 / Float(range)
        }
    }
    
    // also standard in the interface builder
    private var rsltn = 9
    var resolution: Int {
        get {
            rsltn
        }
        set {
            //if newValue <= 4 { rsltn = 4 }
            rsltn = newValue
        }
    }
    
    var hasHighContrast = false
    
    private let luminanceTypes = ["█▇▆▅▄▃▂▁", "█▉▊▋▌▍▎", "█▓▒░", "MXYFIi!:."]
    private var luminanceValues: [Character] = [Character]()
    
    private var divisor: Int = 0
    private var range = 255

    private var factor: Float = 0
    
    var colorInformation: [TextPixel]?
    
    init(luminanceType: LuminanceType = .horizontal) {
        
        self.currentLuminanceType = luminanceType
        // this also calculates other values, so we need to set that too
        self.luminanceType = luminanceType
        
    }
    
    func convertToText(image p: UnsafePointer<UInt8>, length: Int, width: Int, height: Int) -> String {
        
        let res = rsltn
        
        let lv = luminanceValues
        
        var stringImage = String()
        
        let scaledH = height / res
        let scaledW = width / res
        
        // convert the image we just made into strings
        
        let multiplier = factor / Float(divisor)
        
        for h in 0 ..< scaledH {
            var str = String()
            
            let product = h * res * width
            
            for w in 0 ..< scaledW {
                
                let i = (product + width - 1 - w * res) * 4
                
                let luminance = Float(p[i]) * 0.0722 + Float(p[i + 1]) * 0.7152 + Float(p[i + 2]) * 0.2126
                
                str += String( lv[ Int( luminance * multiplier ) ] ) + " "
                
            }
            
            stringImage += str + "\n"
        }
        
        return stringImage
        
    }
    
    func convertToTextField_Color_Scaled(image p: UnsafePointer<UInt8>, length: Int, width: Int, height: Int) -> String {
        
        let res = rsltn
        
        var stringImage = String()
        
        let scaledH = height / res
        let scaledW = width / res
        
        colorInformation = Array(repeating: TextPixel(range: NSRange(), color: NSColor()), count: scaledH * scaledW)
        
        let multiplier = factor / Float(divisor)
        
        var l = 0
        
        for h in 0 ..< scaledH {
            
            var str = String()
            
            let product = h * res * width
            
            for w in 0 ..< scaledW {
                
                let i = (product + width - 1 - w * res) * 4
                
                if hasHighContrast {
                    str += "█ "
                } else {
                    let luminance = Float(p[i]) * 0.0722 + Float(p[i + 1]) * 0.7152 + Float(p[i + 2]) * 0.2126
                    
                    str += String( luminanceValues[ Int( luminance * multiplier ) ] ) + " "
                }
                
                let r = NSMakeRange((h * scaledW + w) * 2 + h, 1)
                
                let color = NSColor(deviceRed: CGFloat(p[i + 2]) / 255, green: CGFloat(p[i + 1]) / 255, blue: CGFloat(p[i]) / 255, alpha: 1 )
                
                colorInformation![l] = TextPixel(range: r, color: color)
                
                l += 1
 
            }
            
            stringImage += str + "\n"
        }
        
        return stringImage
        
    }
    
}
