//
//  CameraAssistant.swift
//  ConsoleApp7
//
//  Created by Cedric Zwahlen on 22.08.21.
//

import Foundation
import AVFoundation

class CameraAssistant {
    
    let captureSession = AVCaptureSession()
    var videoOutput: AVCaptureVideoDataOutput?
    
    let imageQueue = DispatchQueue.init(label: "imageQueue", qos: .userInteractive)
    
    init(delegate: AVCaptureVideoDataOutputSampleBufferDelegate, sessionPreset: AVCaptureSession.Preset = .cif352x288) {
        
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
        captureSession.sessionPreset = sessionPreset
        captureSession.addOutput(videoOutput!)
        captureSession.commitConfiguration()
        
        videoOutput?.setSampleBufferDelegate(delegate, queue: imageQueue)
        
    }
    
    func swapCamera() {
        // Begin new session configuration and defer commit
        captureSession.beginConfiguration()
        
        guard let input = captureSession.inputs[0] as? AVCaptureDeviceInput else { return }
        
        // Create new capture device
        var newDevice: AVCaptureDevice?
        if input.device.position == .back {
            newDevice = captureDevice(with: .front)
        } else {
            newDevice = captureDevice(with: .back)
        }
        
        // Create new capture input
        var deviceInput: AVCaptureDeviceInput!
        do {
            deviceInput = try AVCaptureDeviceInput(device: newDevice!)
        } catch let error {
            print(error.localizedDescription)
            return
        }
        
        // Swap capture device inputs
        captureSession.removeInput(input)
        captureSession.addInput(deviceInput)
        
        captureSession.connections.first!.videoOrientation = .portrait
        
        captureSession.commitConfiguration()
    }
    
    /// Create new capture device with requested position
    private func captureDevice(with position: AVCaptureDevice.Position) -> AVCaptureDevice? {

        let devices = AVCaptureDevice.DiscoverySession(deviceTypes: [ .builtInWideAngleCamera, .builtInMicrophone, .builtInDualCamera, .builtInTelephotoCamera ], mediaType: AVMediaType.video, position: .unspecified).devices

        //if let devices = devices {
            for device in devices {
                if device.position == position {
                    return device
                }
            }
        //}

        return nil
    }
    
}
