import Foundation
import CoreImage
import CoreGraphics

struct ColorTableElement: Hashable, Comparable {
    
    // very specific usecase..
    static func < (lhs: ColorTableElement, rhs: ColorTableElement) -> Bool { lhs.i! < rhs.i! }
    
    static func == (lhs: ColorTableElement, rhs: ColorTableElement) -> Bool {
        lhs.r == rhs.r && lhs.g == rhs.g && lhs.b == rhs.b
    }
    
    
    let r: UInt8
    let g: UInt8
    let b: UInt8
    
    // the "index" of the color in the colortable
    var i: Int?
    
    var tableEntry: String {
        get {
            return "\\red\(r)\\green\(g)\\blue\(b);"
        }
    }
    
    init(_ r: UInt8,_ g: UInt8,_ b: UInt8) {
        self.r = r
        self.g = g
        self.b = b
    }
    
    init(_ rgb: (UInt8,UInt8,UInt8)) {
        self.r = rgb.0
        self.g = rgb.1
        self.b = rgb.2
    }
    
    init(_ r: UInt8,_ g: UInt8,_ b: UInt8, index: Int) {
        self.r = r
        self.g = g
        self.b = b
        self.i = index
    }
    
    init(_ rgb: (UInt8,UInt8,UInt8), index: Int) {
        self.r = rgb.0
        self.g = rgb.1
        self.b = rgb.2
        self.i = index
    }
    
    // override, to exclude i from hashing
    func hash(into hasher: inout Hasher) {
        hasher.combine(r)
        hasher.combine(g)
        hasher.combine(b)
    }
    
}

func logC(val: Double, forBase base: Double) -> Double {
    return log(val)/log(base)
}


public func convertToConsole(image p: UnsafeMutablePointer<UInt8>, length: Int, width: Int, height: Int) -> String {
    
    // with imageIO, it seems the alpha value is the first value in the pixel so its argb
    
    //print("The image is \(width) pixels wide, and \(height) pixels high.")
    
    // MARK: START PRINT IMAGE REPRESENTATION

    let altStr = "█▇▆▅▄▃▂▁ "

    let toUse = altStr
    
    var luminanceValues: [Character] = [Character]()
    for c in toUse { luminanceValues.append(c) }

    let divisor: Int = 255 / (luminanceValues.count - 1)
    var brightest: UInt8 = 0
    var darkest: UInt8 = 255
    
    // first, go through and find the brightest and darkest pixels
    for pxl in 0 ..< width * height {
        
        let luminance = UInt8( ( Float(p[pxl * 4 + 1]) + Float(p[pxl * 4 + 2]) + Float(p[pxl * 4 + 3]) ) / 3 )
        
        // so we only calcualte the luminance once, we put that information into the alpha component of every pixel. We can't really utilise the alpha value anyways, so we can use it to optimise the program a little.
        p[pxl * 4] = luminance
      
        brightest = luminance > brightest ? UInt8(luminance) : UInt8(brightest)
        darkest = luminance < darkest ? UInt8(luminance) : UInt8(darkest)
        
    }
    
    let range = brightest - darkest
    let factor = 255 / Float(range)
    
    //print("Contrast information: brightest: \(brightest), darkest: \(darkest), range: \(range), factor: \(factor)")
    
    var stringImageRef = Array(repeating: String(""), count: width * height)
    for pxl in 0 ..< width * height {
        
        let l = luminanceValues[ Int( Float(p[pxl * 4] - darkest) * factor ) / divisor ]
        
        let red: Float = (Float(p[pxl * 4 + 1]) / 255) * 5
        let green: Float = (Float(p[pxl * 4 + 2]) / 255) * 5
        let blue: Float = (Float(p[pxl * 4 + 3]) / 255) * 5

        let consoleColorIndex = String(Int(16 + 36 * red + 6 * green + blue))
        
        stringImageRef[pxl] = "\u{001B}[38;5;\(consoleColorIndex)m\(l)\u{001B}[0;0m"
        
    }
    
    var stringImage = ""
    
    stringImage += "╔" + String(repeating: "═", count: width * 2 - 1) + "╗\n"
    
    // convert the image we just made into strings
    for h in 0 ..< height {
        var str = ""
        for w in 0 ..< width { str += (String(stringImageRef[h * width + w]) + " ") }
        // remove the last 
        stringImage += "║" + str.dropLast() + "║\n"
    }
    
    stringImage += "╚" + String(repeating: "═", count: width * 2 - 1) + "╝\n"
    
    return stringImage
    
    // MARK: END PRINT IMAGE REPRESENTATION

}

// to specifies how many colors can exist of that component. 8 would create 8 shades of that color.
public func limitColorComponent(of clr: UInt8, to div: UInt8) -> UInt8 {
    
    let factor = 255 / div
    
    return clr / factor * factor
    
}

public func limitComponentsOf(_ pixel: UnsafeMutablePointer<UInt8>, offest: Int, to div: UInt8) -> (UInt8,UInt8,UInt8) {
    
    return ( limitColorComponent(of: pixel[offest * 4 + 1], to: div), limitColorComponent(of: pixel[offest * 4 + 2], to: div), limitColorComponent(of: pixel[offest * 4 + 3], to: div) )
}

public func convertToText(image p: UnsafeMutablePointer<UInt8>, length: Int, width: Int, height: Int, colors: UInt8, contrast: Bool) -> String {
    
    // with imageIO, it seems the alpha value is the first value in the pixel so its argb
    
    //print("The image will be \(width) 'pixels' wide, and \(height) pixels high.")
    
    // MARK: START PRINT IMAGE REPRESENTATION

    let toUse: String

    if contrast { toUse = "██" } else { toUse = "█▇▆▅▄▃▂▁ " }
    
    var luminanceValues: [Character] = [Character]()
    for c in toUse { luminanceValues.append(c) }

    let divisor: Int = 255 / (luminanceValues.count - 1)
    var brightest: UInt8 = 0
    var darkest: UInt8 = 255
    
    var colorTable: Set<ColorTableElement> = Set<ColorTableElement>()
    
    var insertIndex = 0
    
    // first, go through and find the brightest and darkest pixels, also set up a colortable
    for pxl in 0 ..< width * height {
        
        let luminance = UInt8( ( Float(p[pxl * 4 + 1]) + Float(p[pxl * 4 + 2]) + Float(p[pxl * 4 + 3]) ) / 3 )
        
        // so we only calcualte the luminance once, we put that information into the alpha component of every pixel. We can't really utilise the alpha value anyways, so we can use it to optimise the program a little.
        p[pxl * 4] = luminance
        
        // insert the pixels into the colortable. It's a set, so they are not duplicated.
        if colorTable.insert(ColorTableElement(limitComponentsOf(p, offest: pxl, to: colors), index: insertIndex)).inserted { insertIndex += 1 }
      
        brightest = luminance > brightest ? UInt8(luminance) : UInt8(brightest)
        darkest = luminance < darkest ? UInt8(luminance) : UInt8(darkest)
        
    }
    
    let range = brightest - darkest
    let factor = 255 / Float(range)
    
    //print("Contrast information: brightest: \(brightest), darkest: \(darkest), range: \(range), factor: \(factor)")
    
    var stringImageRef = Array(repeating: String(""), count: width * height)
    for pxl in 0 ..< width * height {
        
        let l = luminanceValues[ Int( Float(p[pxl * 4] - darkest) * factor ) / divisor ]
        
        // here, we get the index for the color we put into the table earlier.
        let i = colorTable.first(where: { $0 == ColorTableElement(limitComponentsOf(p, offest: pxl, to: colors)) })!.i!
        
        
        
        // plus two, because we already added black and white to the color table. these will always be present, so we need to offset the remaining values.
        stringImageRef[pxl] = "\\cf\(i + 2)\\uc0\\u\(l.unicodeScalars.first!.value)"
        
    }
    
    //print("There are \(colorTable.count) colors in this image.")
    
    var colors = ""
    
    for e in colorTable.sorted(by: <) { colors += e.tableEntry }
    
    var stringImage = ""
    
    stringImage += "\\cf1\\uc0\\u9556" + String(repeating: "\\u9552", count: width * 2 - 1) + "\\u9559\\line"
    
    // convert the image we just made into strings
    for h in 0 ..< height {
        var str = ""
        for w in 0 ..< width { str += (String(stringImageRef[h * width + w]) + "  ") }
        // remove the last
        stringImage += "\\cf1\\uc0\\u9553" + str.dropLast() + "\\cf1\\uc0\\u9553\\line"
    }
    
    stringImage += "\\cf1\\uc0\\u9562" + String(repeating: "\\u9552", count: width * 2 - 1) + "\\u9565\\line"
    
    //calculate the fontsize... phew. basically it's y = 1024 *0.5^(x * 0.5), but we want to know x not y.
    let fontSize = Int(-2.88539 * ( logC(val: Double(max(height,width)), forBase: 2.71828)-6.93147))
    
    // multiplication by 20 to compensate for twips
    // fontsize * x to compensate for the scrollbar and window
    let windowW = 20 * width * fontSize + fontSize * 10
    let windowH = 20 * height * fontSize + fontSize * 240

    let preamble =
        """
        {\\rtf1\\ansi
        {\\fonttbl\\f0\\fswiss\\fcharset0 Inconsolata;}
        {\\colortbl\\red255\\green255\\blue255;\\red0\\green0\\blue0;\(colors)}
        \\vieww\(Int(windowW))\\viewh\(Int(windowH))\\paperw\(Int(20 * width * fontSize))\\paperh\(Int(20 * height * fontSize))
        
        \\f0\\fs\(fontSize * 2)\(stringImage)}
        """
    
    return preamble
    
    // MARK: END PRINT IMAGE REPRESENTATION

}
