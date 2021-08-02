//
//  ImageConversion.swift
//  ConsoleApp7_Now_Streaming
//
//  Created by Cedric Zwahlen on 30.07.21.
//

import Foundation
import Cocoa

class StreamToString {
    
    /*
    private struct TextPixel {
        let char: Character
        let color: NSColor
    }
    
    private struct TextPixelBW {
        let char: Character
    }
    */
    
    private let luminanceInfo = "█▇▆▅▄▃▂▁ "
    private var luminanceValues: [Character] = [Character]()
    
    private let divisor: Int
    private var range = 255
    
    private let factor: Float
    
    init() {
        
        for c in luminanceInfo { luminanceValues.append(c) }
        
        if range <= luminanceValues.count { range = 255 }
        
        divisor = 255 / (luminanceValues.count - 1)
        factor = 255 / Float(range)
        
    }
    
    func convertToTextField(image p: inout UnsafeMutablePointer<UInt8>, length: Int, width: Int, height: Int) -> String {
        
        var stringImage = String()
        
        // convert the image we just made into strings
        
        let multiplier = factor / Float(divisor)
        
        for h in 0 ..< height {
            var str = String()
            
            let product = h * width
            
            for w in 0 ..< width {
                
                let i = (product + width - 1 - w) * 4
                
                let luminance = Float(p[i]) * 0.0722 + Float(p[i + 1]) * 0.7152 + Float(p[i + 2]) * 0.2126
                
                str += String( luminanceValues[ Int( luminance * multiplier ) ] ) + " "
                
            }
            
            stringImage += str + "\n"
        }
        
        return stringImage
        
        // MARK: END PRINT IMAGE REPRESENTATION
        
    }
    
}
