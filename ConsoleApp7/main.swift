//
//  main.swift
//  ConsoleApp7
//
//  Created by Cedric Zwahlen on 21.05.21.
//

import Foundation
import CoreGraphics
import ImageIO

struct ImageSetting {
    var maxSize: Int = 128
    var fileName: String = ""
    var colors: UInt8 = 8
    var noCompression: Bool = false
    var increaseContrast: Bool = false
}

func resizedImage(at url: URL, for size: CGSize) -> CGImage? {
    let options: [CFString: Any] = [
        kCGImageSourceCreateThumbnailFromImageIfAbsent: true,
        kCGImageSourceCreateThumbnailWithTransform: true,
        kCGImageSourceShouldCacheImmediately: true,
        kCGImageSourceThumbnailMaxPixelSize: max(size.width, size.height)
    ]

    guard let imageSource = CGImageSourceCreateWithURL(url as NSURL, nil),
        let image = CGImageSourceCreateThumbnailAtIndex(imageSource, 0, options as CFDictionary)
    else {
        return nil
    }

    return image
}

func resizedImage(at url: URL) -> CGImage? {
    let options: [CFString: Any] = [
        kCGImageSourceCreateThumbnailFromImageIfAbsent: true,
        kCGImageSourceCreateThumbnailWithTransform: true,
        kCGImageSourceShouldCacheImmediately: true
    ]

    guard let imageSource = CGImageSourceCreateWithURL(url as NSURL, nil),
        let image = CGImageSourceCreateThumbnailAtIndex(imageSource, 0, options as CFDictionary)
    else {
        return nil
    }

    return image
}


clear()

print(
"""
Bonjour! Welcome to ConsoleApp7, the only app you'll ever need.
Give me an \u{001B}[35;1mimage\u{001B}[0;0m, and see what happens.

If you need help, you can always leave. Or, type \u{001B}[1m-help\u{001B}[0;0m I guess.

Please, enter a path to an image below. Down there ↓
""")

while true {
    
    var url: URL?

    var settings = ImageSetting()
     
    while true {
        
        let line = readLine()
        
        if line == "gay" {
            print("Yes! 🌈")
        }
        
        // look at the link, and verify it. Also check for escape sequences and apply them.
        
        if let setting = line, setting.starts(with: "-") {
            
            for str in setting.split(separator: "-") {
                if str.starts(with: "size"), let size = Int(str.trimmingCharacters(in: .decimalDigits.inverted)) {
                    
                    let s: Int
                    if size > 512 { s = 512; print("Uh Oh, values above 512 are not allowed. :(") }
                    else if size < 4 { s = 4; print("Listen, values below 4 are literally not possible. Sorry") } else { s = size }
                    
                    print("The maximum size of the image will be \(s). You might need to scroll a bit, though.")
                    settings.maxSize = size
                }
                
                if str.starts(with: "fileName") {
                    let name = str.replacingOccurrences(of: "fileName ", with: "").replacingOccurrences(of: ".rtf", with: "")
                    print("Yes. Filename. New. It's gonna be \"\(name).rtf\". Love it.")
                    settings.fileName = name + ".rtf"
                }
                
                if str.starts(with: "colors"), let cls = Int(str.trimmingCharacters(in: .decimalDigits.inverted)) {
                    
                    let c: UInt8
                    if cls > 255 { c = 255 }
                    else if cls < 1 { c = 1;  } else { c = UInt8(cls) }
                    
                    print("Ok. The Image will allow \(c) colors per component.")
                    
                    settings.colors = c
                }
                
                if str.starts(with: "fuckthatbitch") {
                    settings.noCompression.toggle()
                    if settings.noCompression {
                        print("Previously specified 'size' and 'colors' values will be ignored.\nYou are crazy.")
                    } else {
                        print("The image will be generated with bounds-checked values.")
                    }
                    
                }
                
                if str.starts(with: "contrast") {
                    settings.increaseContrast.toggle()
                    if settings.increaseContrast {
                        print("The contrast of the image will be increased.")
                    } else {
                        print("The contrast is restored to normal.")
                    }
                    
                }
                
                if str.starts(with: "help") {
                    
                    print(
                        """
                        
                        Hello. I am help. 🌞
                        
                        You can adjust several settings, to change the way the final image will look like.
                        To do this, type any of the keywords below, and a legal value into the console.
                        Any values specified between the asterisks will work.
                        ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─
                        
                        \u{001B}[32;1m-size\u{001B}[0;0m *4...512*
                        
                        Adjusts the size of the image. Values below 4 and above 512 are not allowed.
                        ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─
                        
                        \u{001B}[32;1m-colors\u{001B}[0;0m *1...255*
                        
                        Changes how many colors per component are possible. There are three components per pixel.
                        A value of 1 results in a black and white image.
                        Values above 64 can make the program inconceivably slow.
                        ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─
                        
                        \u{001B}[32;1m-fileName\u{001B}[0;0m *filename*
                        
                        The name your new image should have.
                        If there is already file with that name and the extension '.rtf' in the destination folder, it will be replaced!
                        ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─
                        
                        \u{001B}[32;1m-contrast\u{001B}[0;0m
                                                
                        Calculates the contrast information differently. See for yourself.
                        ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─
                        
                        \u{001B}[31;1m-fuckthatbitch\u{001B}[0;0m
                        
                        Applies *almost* no compression to the image, resulting in an enourmous '.rtf' file and a \u{001B}[1mvery\u{001B}[0;0m long computing time.
                        Don't try this at home, kids.
                        ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─
                                       
                        
                        """)
                    
                }
                
                
                
            }
            continue
        }
        
        if let p = line?.trimmingCharacters(in: .whitespaces) {
            
            let path = String(p).replacingOccurrences(of: "\\", with: "")
            
            if FileManager.default.fileExists(atPath: path ) {
                
                if settings.fileName == "" {
                    let s = String(path.split(separator: "/").last!)
                    settings.fileName = String(s[..<s.lastIndex(of: ".")!]) + ".rtf"
                }
                
                print("Ah, there it is! Well lets get going.\n...")
                url = URL(fileURLWithPath: path)
                break
            } else { print("Hmmm... I couldn't find anything at that path.") }
        }
    }

    
    let imageRef: CGImage

    if settings.noCompression {
        imageRef = resizedImage(at: url!, for: CGSize(width: 1024, height: 1024))!
        settings.colors = 64
    } else {
        // 512 IS THE MAX for rtf, 256 for the console
        imageRef = resizedImage(at: url!, for: CGSize(width: settings.maxSize, height: settings.maxSize))!
    }

    

    // it's data
    var d = imageRef.dataProvider?.data
    // and length
    let range = CFRangeMake(0,CFDataGetLength(d))

    // allocate the pointer
    let p: UnsafeMutablePointer<UInt8> = UnsafeMutablePointer<UInt8>.allocate(capacity: range.length)

    // copy (not reference) the pixels of d into p
    CFDataGetBytes(d, range, p)



    // that's all we need (assume 4 components )
    // apparently, we can't just take the width of the image. This results in some weird behaviour. Instead, calculate the width by dividing the length of the range by four, and then by the height
    
    let stringImage = convertToText(image: p, length: range.length, width: range.length / (imageRef.height * 4), height: imageRef.height, colors: settings.colors, contrast: settings.increaseContrast)

    saveToFile(str: stringImage, file: settings.fileName)

    p.deallocate()

    // counts as deinit?
    d = nil

    print("\nTo convert another image, press any key.")
    
    _ = readLine()

    clear()
}
