//
//  ViewController.swift
//  ConsoleApp7_Mobile
//
//  Created by Cedric Zwahlen on 22.08.21.
//

import UIKit
import AVFoundation

class ViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate, UITableViewDelegate, UITableViewDataSource, UITextViewDelegate {

    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var tableView: UITableView!
    
    var cam: CameraAssistant?
    let videoToText = VideoToText()
    
    private var cell1 = ButtonCell()
    private var cell2 = ButtonCell()
    private var slider = UISlider()
    private var segment = UISegmentedControl()
    
    // this is all just so i can copy stuff 1:1 from the macos stuff
    var pauseButton: UIButton {
        cell1.button2
    }
    
    var snapshotButton: UIButton {
        cell1.button1
    }
    
    var contrastButton: UIButton {
        cell2.button1
    }
    
    var colorModeButton: UIButton {
        cell2.button2
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        cam = CameraAssistant(delegate: self, sessionPreset: .vga640x480)
        cam?.captureSession.connections.first!.videoOrientation = .portrait
        cam?.captureSession.connections.first!.isVideoMirrored = true
        
        textView.delegate = self
        textView.textAlignment = .center
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = 55
        
        //contrastButton.isEnabled = false
        
        colorFunc = videoToText.convertToText(image:length:width:height:xOffset:yOffset:xFrame:yFrame:)
        
        formatter.dateStyle = .long
        formatter.timeStyle = .long
        
        cam?.captureSession.startRunning()
       
        
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == 0 && indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "ButtonCell") as! ButtonCell
            
            cell.configure(f1: snapshot, bttn1: "Snapshot", f2: pause, bttn2: "Pause")
            
            cell1 = cell
            
            return cell
        }
        if indexPath.section == 1 && indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "ButtonCell") as! ButtonCell
            
            cell.configure(f1: contrast, bttn1: "Increase Contrast", f2: colorBttn, bttn2: "Multicolor")
            
            cell2 = cell
            
            return cell
        }
        if indexPath.section == 2 && indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "SliderCell") as! SliderCell
            
            slider = cell.slider
            
            slider.addTarget(self, action: #selector(slide), for: .touchUpInside)
            
            slide()
            
            return cell
        }
        if indexPath.section == 3 && indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "SegmentCell") as! SegmentCell
            
            segment = cell.segment
            
            segment.addTarget(self, action: #selector(segmentSelected), for: .touchUpInside)
            
            return cell
        }
        
        
        print("non.")
        return UITableViewCell()
        
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        1
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        switch section {
        case 0:
            return "Controls"
        case 1:
            return "Color Setting"
        case 2:
            return "Shading Mode"
        case 3:
            return "Resolution"
        default:
            print("non.")
            return "bitch!"
        }
        
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        4
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
        present( colorFunc!(p, range.length, range.length / (iHeight * 4), iHeight, 100, 0, 250, 400) )
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
    
    var colorFunc: ( ( UnsafePointer<UInt8>, Int, Int, Int, Int, Int, Int, Int ) -> String )? = nil
    var isBW = true
    func colorBttn() {
        isBW.toggle()
        
        if !isBW && slider.value >= 13 {
            slider.value = 13
            slide()
        }
        
        videoToText.colorInformation = nil
        textView.backgroundColor = isBW ? .white : .black
        
        if isBW {
            textView.textColor = .black
            colorFunc = videoToText.convertToText(image:length:width:height:xOffset:yOffset:xFrame:yFrame:)
            colorModeButton.setTitle("Multicolor", for: .normal)
            
            contrastButton.isEnabled = false
        } else {
            colorFunc = videoToText.convertToText_Color_Scaled(image:length:width:height:xOffset:yOffset:xFrame:yFrame:)
            colorModeButton.setTitle("Black & White", for: .normal)
            contrastButton.isEnabled = true
        }
    }
    
    let formatter = DateFormatter()
    func snapshot() {
        /*
        if let file = textView), documentAttributes: [:]), let dir = FileManager.default.urls(for: .downloadsDirectory, in: .userDomainMask).first {
            
            let fileURL = dir.appendingPathComponent("Snapshot - \(formatter.string(from: NSDate.now)).rtf")
            
            //writing
            do {
                
                try file.write(to: fileURL)
                
            } catch { print("Could not save the image.") }
        }
        */
    }
    
    func pause() {
        if cam!.captureSession.isRunning {
            cam!.captureSession.stopRunning()
            pauseButton.setTitle("Continue", for: .normal)
        } else {
            cam!.captureSession.startRunning()
            pauseButton.setTitle("Pause", for: .normal)
        }
    }
    
    func contrast() {
        videoToText.hasHighContrast.toggle()
        
        if videoToText.hasHighContrast {
            contrastButton.setTitle("Decrease Contrast", for: .normal)
        } else {
            contrastButton.setTitle("Increase Contrast", for: .normal)
        }
        
    }
    
    @objc func segmentSelected() {
        videoToText.luminanceType = VideoToText.LuminanceType.init(rawValue: segment.selectedSegmentIndex)!
    }
    
    var fontSize: CGFloat = 4
    @objc func slide() {
        
        // in colormode, we cant go lower
        if !isBW && slider.value >= 13 {
            slider.value = 13
        }
        
        videoToText.resolution = Int(slider.maximumValue) + 1 - Int(slider.value)
        fontSize = CGFloat(videoToText.resolution)
        textView.font = .monospacedSystemFont(ofSize: fontSize, weight: .regular)
        
    }
    

}

