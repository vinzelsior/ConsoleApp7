//
//  ViewController.swift
//  ConsoleApp7_Now_Streaming
//
//  Created by Cedric Zwahlen on 30.07.21.
//

import Cocoa
import AVFoundation

class ViewController: NSViewController, AVCaptureVideoDataOutputSampleBufferDelegate, NSTextViewDelegate {
    
    @IBOutlet var textView: NSTextView!
    
    @IBOutlet weak var colorModeButton: NSButton!
    @IBOutlet weak var snapshotButton: NSButton!
    @IBOutlet weak var pauseButton: NSButton!
    @IBOutlet weak var contrastButton: NSButton!
    @IBOutlet weak var resolutionSlider: NSSlider!
    @IBOutlet weak var segmentControl: NSSegmentedControl!
    @IBOutlet weak var continuousPixelButton: NSButton!
    
    var cam: CameraAssistant?
    
    let videoToText = VideoToText()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        cam = CameraAssistant(delegate: self)
        
        videoToText.resolution = Int(resolutionSlider.maxValue) + 1 - resolutionSlider.integerValue
        fontSize = CGFloat(videoToText.resolution)
        
        textView.delegate = self
        textView.font = .monospacedSystemFont(ofSize: fontSize * 2, weight: .regular)
        textView.alignment = .center
        
        contrastButton.isEnabled = false
        
        segmentControl.selectedSegment = 0
        
        colorFunc = videoToText.convertToText(image:length:width:height:xOffset:yOffset:xFrame:yFrame:)
        
        formatter.dateStyle = .long
        formatter.timeStyle = .long
        
        cam!.captureSession.startRunning()
        
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    
    
    // MARK: AVCaptureVideoDataOutputSampleBufferDelegate

    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        
        guard let imageBuffer =  sampleBuffer.imageBuffer, let img = CGImage.create(pixelBuffer: imageBuffer) else { return }
       
        let d = img.dataProvider?.data
    
        let range = CFRangeMake(0,CFDataGetLength(d))
        
        // refrence the data
        let p = CFDataGetBytePtr(d)!
        
        let iHeight = img.height
        //let iWidth = range.length / (iHeight * 4)
        
        // standard for computer
        present( colorFunc!(p, range.length, range.length / (iHeight * 4), iHeight, 0, 12, -1, iHeight - 24) )
        //present( colorFunc!(p, range.length, iWidth, iHeight, 30, 12, 150, 200) )
        
    }
    
    func present(_ str: String) {
        
        // we update synchronously, because the captureOutput function actually waits until we are out of it's scope until it delivers the next frame.
        // this way, we always get the maximum framerate
        DispatchQueue.main.sync { [self] in
            
            textView.string = str
            
            if let colorInfo = videoToText.colorInformation {
                
                for textColor in colorInfo {
                    textView.textStorage?.addAttributes([ NSAttributedString.Key.foregroundColor : textColor.color ], range: textColor.range)
                }
            }
        }
    }
    
    var colorFunc: ( ( UnsafePointer<UInt8>, Int, Int, Int, Int, Int, Int, Int ) -> String )? = nil
    var isBW = true
    @IBAction func colorButtonPressed(_ sender: Any) {
        isBW.toggle()
        
        if !isBW && resolutionSlider.integerValue >= 13 {
            resolutionSlider.integerValue = 13
            sliderChanged(resolutionSlider)
        }
        
        videoToText.colorInformation = nil
        textView.backgroundColor = isBW ? .white : .black
        
        if isBW {
            textView.textColor = .black
            colorFunc = videoToText.convertToText(image:length:width:height:xOffset:yOffset:xFrame:yFrame:)
            colorModeButton.title = "Multicolor"
            contrastButton.isEnabled = false
        } else {
            colorFunc = videoToText.convertToText_Color_Scaled(image:length:width:height:xOffset:yOffset:xFrame:yFrame:)
            colorModeButton.title = "Black & White"
            contrastButton.isEnabled = true
        }
        
    }
    
    let formatter = DateFormatter()
    @IBAction func snapshotButtonPressed(_ sender: Any) {
        
        if let file = textView.textStorage?.rtf(from: NSMakeRange(0, textView.string.count), documentAttributes: [:]), let dir = FileManager.default.urls(for: .downloadsDirectory, in: .userDomainMask).first {
            
            let fileURL = dir.appendingPathComponent("Snapshot - \(formatter.string(from: NSDate.now)).rtf")
            
            //writing
            do {
                
                try file.write(to: fileURL)
                
            } catch { print("Could not save the image.") }
        }
    }
    
    @IBAction func pauseButtonPressed(_ sender: Any) {
        
        if cam!.captureSession.isRunning {
            cam!.captureSession.stopRunning()
            pauseButton.title = "Continue"
        } else {
            cam!.captureSession.startRunning()
            pauseButton.title = "Pause"
        }
        
    }
    
    @IBAction func contrastButtonPressed(_ sender: Any) {
        videoToText.hasHighContrast.toggle()
        
        if videoToText.hasHighContrast {
            contrastButton.title = "Decrease Contrast"
        } else {
            contrastButton.title = "Increase Contrast"
        }
        
    }
    
    @IBAction func continuousPixelButtonPressed(_ sender: Any) {
        
        videoToText.continuousPixels.toggle()
        
        if videoToText.continuousPixels {
            continuousPixelButton.title = "Pixel-Perfect"
        } else {
            continuousPixelButton.title = "Continuous Pixels"
        }
        
    }
    
    
    @IBAction func segmentControlChanged(_ sender: NSSegmentedControl) {
        videoToText.luminanceType = VideoToText.LuminanceType.init(rawValue: sender.selectedSegment)!
    }
    
    var fontSize: CGFloat = 9
    @IBAction func sliderChanged(_ sender: NSSlider) {
        
        // in colormode, we cant go lower
        if !isBW && sender.integerValue >= 13 {
            sender.integerValue = 13
        }
        
        videoToText.resolution = Int(sender.maxValue) + 1 - sender.integerValue
        fontSize = CGFloat(videoToText.resolution)
        textView.font = .monospacedSystemFont(ofSize: fontSize * 2, weight: .regular)
    }
    
}

