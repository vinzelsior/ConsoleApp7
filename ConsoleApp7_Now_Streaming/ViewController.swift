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
    
    
    let captureSession = AVCaptureSession()
    var videoOutput: AVCaptureVideoDataOutput?
    
    let imageQueue = DispatchQueue.init(label: "imageQueue", qos: .userInteractive)
    
    let streamToString = StreamToString()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        captureSession.beginConfiguration()
        let videoDevice = AVCaptureDevice.default(.builtInWideAngleCamera,
                                                  for: .video, position: .unspecified)
        guard
            let videoDeviceInput = try? AVCaptureDeviceInput(device: videoDevice!),
            captureSession.canAddInput(videoDeviceInput)
            else { return }
        captureSession.addInput(videoDeviceInput)
        
        videoOutput = AVCaptureVideoDataOutput()
        guard captureSession.canAddOutput(videoOutput!) else { return }
        captureSession.sessionPreset = .cif352x288
        captureSession.addOutput(videoOutput!)
        captureSession.commitConfiguration()

        for conn in captureSession.connections {
            if conn.isVideoMinFrameDurationSupported {
                //conn.videoMinFrameDuration = CMTime(seconds: 1, preferredTimescale: 1)
            }
        }
        videoOutput?.setSampleBufferDelegate(self, queue: imageQueue)
        
        captureSession.startRunning()
    
        
        
        
        
        textView.delegate = self
        textView.font = NSFont.monospacedSystemFont(ofSize: 2, weight: .regular)
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    
    // MARK: AVCaptureVideoDataOutputSampleBufferDelegate

    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        
        guard let imageBuffer =  sampleBuffer.imageBuffer, let img = CGImage.create(pixelBuffer: imageBuffer) else { return }
        
        // it's data
        let d = img.dataProvider?.data
        // and length
        let range = CFRangeMake(0,CFDataGetLength(d))
        
        // allocate the pointer
        var p: UnsafeMutablePointer<UInt8> = UnsafeMutablePointer<UInt8>.allocate(capacity: range.length)
        
        // copy (not reference) the pixels of d into p
        CFDataGetBytes(d, range, p)
        
        
        
        present( streamToString.convertToTextField(image: &p, length: range.length, width: range.length / (img.height * 4), height: img.height) )
        
        // might be illegal, because this pool belongs to the session
        p.deallocate()
        
    }
    
    // MARK: NSTextViewDelegate
    
    func textDidChange(_ notification: Notification) {
        //print(textView.textStorage?.string)
    }
    
    // this is needed, because otherwise we actually calculate the images too fast!
    private var skip = false
    func present(_ str: String) {
        
        if skip { return }
        
        DispatchQueue.main.async { [self] in
            skip = true
            textView.string = str
            skip = false
        }
        
    }
    
}

