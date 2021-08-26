//
//  ViewController.swift
//  ConsoleApp7_Mobile
//
//  Created by Cedric Zwahlen on 22.08.21.
//

import UIKit
import AVFoundation

class ViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate, UITextViewDelegate, ControlHandling {
    @IBOutlet weak var captureButton: UIButton!
    
    @IBOutlet weak var flipCameraButton: UIButton!
    
    @IBOutlet weak var settingsButton: UIButton!
    
    @IBOutlet weak var pauseButton: UIButton!
    
    @IBOutlet weak var blurView: UIVisualEffectView!
    
    @IBOutlet weak var container: UIView!
    
    @IBOutlet weak var textView: UITextView!
    var settingsVC: SettingsViewController?
    
    var cam: CameraAssistant?
    let videoToText = VideoToText()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        settingsVC = self.children.first as? SettingsViewController
        settingsVC?.delegate = self
        settingsVC?.view.alpha = 0
        settingsVC?.view.layer.cornerRadius = 10
        settingsVC?.view.clipsToBounds = true
        
        cam = CameraAssistant(delegate: self, sessionPreset: .vga640x480)
        cam?.captureSession.connections.first!.videoOrientation = .portrait
        cam?.captureSession.connections.first!.isVideoMirrored = true
        
        textView.delegate = self
        textView.textAlignment = .center
       
        colorFunc = videoToText.convertToText(image:length:width:height:xOffset:yOffset:xFrame:yFrame:)
        
        //formatter.dateStyle = .long
        //formatter.timeStyle = .long
        
        blurView.effect = nil
        blurView.isHidden = true
        blurView.alpha = 1
        
        textView.backgroundColor = isBW ? .white : .black
        textView.textColor = .black
        view.backgroundColor = isBW ? .white : .black
        
        
        cam?.captureSession.startRunning()
       
        
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        segmentSelected(index: settingsVC!.segment!.selectedSegmentIndex)
        sliderChanged(value: settingsVC!.slider!.value)
        settingsVC?.bttn1?.isEnabled = false
    }
    
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        
        guard let imageBuffer =  sampleBuffer.imageBuffer, let img = CGImage.create(pixelBuffer: imageBuffer) else { return }
       
        let d = img.dataProvider?.data
    
        let range = CFRangeMake(0,CFDataGetLength(d))
        
        // refrence the data
        let p = CFDataGetBytePtr(d)!
        
        let iHeight = img.height
        //let iWidth = range.length / (iHeight * 4)
        
        // vga640x480
        present( colorFunc!(p, range.length, range.length / (iHeight * 4), iHeight, 50, 0, 250, 400) )
        //present( colorFunc!(p, range.length, iWidth, iHeight, 30, 12, 150, 200) )
        
    }
    
    func present(_ str: String) {
        
        // we update synchronously, because the captureOutput function actually waits until we are out of it's scope until it delivers the next frame.
        // this way, we always get the maximum framerate
        DispatchQueue.main.sync { [self] in
            
            textView.text = str
            
            if let colorInfo = videoToText.colorInformation {
                for textColor in colorInfo {
                    textView.textStorage.addAttributes([ NSAttributedString.Key.foregroundColor : textColor.color ], range: textColor.range)
                }
            }
        }
    }
    
    // 10 -> capture
    // 20 -> flip
    // 30 -> settings
    @IBAction func buttonPressed(_ sender: Any) {
        
        let tag = (sender as! UIButton).tag
        
        if tag == 30 {
            
            blur(blurView)
        }
        
    }
    
    
    var colorFunc: ( ( UnsafePointer<UInt8>, Int, Int, Int, Int, Int, Int, Int ) -> String )? = nil
    var isBW = true
    
    // 10 -> Increase Contrast
    // 20 -> Multicolor
    func buttonPressed(tag: Int) {
        
        if tag == 10 {
            videoToText.hasHighContrast.toggle()
        }
        
        if tag == 20 {
            isBW.toggle()
            
            if !isBW && settingsVC!.slider!.value >= 13 {
                settingsVC!.slider!.value = 13
                segmentSelected(index: Int(settingsVC!.slider!.value))
            }
            
            videoToText.colorInformation = nil
            textView.backgroundColor = isBW ? .white : .black
            view.backgroundColor = isBW ? .white : .black
            
            if isBW {
                textView.textColor = .black
                colorFunc = videoToText.convertToText(image:length:width:height:xOffset:yOffset:xFrame:yFrame:)
                settingsVC!.bttn2!.setTitle("Multicolor", for: .normal)
                settingsVC!.bttn1!.isEnabled = false
            } else {
                colorFunc = videoToText.convertToText_Color_Scaled(image:length:width:height:xOffset:yOffset:xFrame:yFrame:)
                settingsVC!.bttn2!.setTitle("Black & White", for: .normal)
                settingsVC!.bttn1!.isEnabled = true
            }
        }
        
    }
    
    var fontSize: CGFloat = 4
    func sliderChanged(value: Float) {
        
        // in colormode, we cant go lower
        if !isBW && settingsVC!.slider!.value >= 13 {
            settingsVC!.slider!.value = 13
        }
        
        videoToText.resolution = Int(settingsVC!.slider!.maximumValue + 1 - settingsVC!.slider!.value)
        fontSize = CGFloat(videoToText.resolution)
        textView.font = .monospacedSystemFont(ofSize: fontSize, weight: .regular)
        
    }
    
    func segmentSelected(index: Int) {
        videoToText.luminanceType = VideoToText.LuminanceType.init(rawValue: index)!
    }
    
    @IBAction func pause(_ sender: Any) {
        if cam!.captureSession.isRunning {
            cam!.captureSession.stopRunning()
            pauseButton.setTitle("Continue", for: .normal)
        } else {
            cam!.captureSession.startRunning()
            pauseButton.setTitle("Pause", for: .normal)
        }
    }
    
    @IBAction func flipCamera(_ sender: Any) {
        
        cam?.swapCamera()
        
    }
    
    
    
    func blur(_ view: UIView) {
        
        blurView.isHidden = false
        self.view.bringSubviewToFront(container)
        
        if let effectView = view as? UIVisualEffectView {
            UIView.animate(withDuration: 0.2) { [self] () -> Void in
                effectView.effect = UIBlurEffect(style: .dark)
                settingsVC?.view.alpha = 1
            }
        }
        
        
    }
    
    
    
    
}

