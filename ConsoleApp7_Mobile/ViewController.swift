//
//  ViewController.swift
//  ConsoleApp7_Mobile
//
//  Created by Cedric Zwahlen on 22.08.21.
//

import UIKit
import AVFoundation

class ViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate {

    
    let captureSession = AVCaptureSession()
    var videoOutput: AVCaptureVideoDataOutput?
    
    let imageQueue = DispatchQueue.init(label: "imageQueue", qos: .userInteractive)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
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
        
        videoOutput?.setSampleBufferDelegate(self, queue: imageQueue)
        
    }


}

