//
//  Camera.swift
//  CameraFramework
//
//  Created by Daval Cato on 6/23/19.
//  Copyright © 2019 Daval Cato. All rights reserved.
//

import UIKit
import AVFoundation

protocol CameraDelegate {
    func stillImageCaptured(camera: Camera, image: UIImage)
    
    
    
}

class Camera: NSObject {
    var delegate: CameraDelegate?
    var controller: CameraViewController?
    
    var position: CameraPosition = .back {
        didSet {
            if self.session.isRunning {
                self.session.stopRunning()
                update()
                
            }
            
        }
    }
    
    required init(with controller: CameraViewController) {
        self.controller = controller
    }
    
    fileprivate var session = AVCaptureSession()
    fileprivate var discoverySession: AVCaptureDevice.DiscoverySession? {
        return AVCaptureDevice.DiscoverySession(deviceTypes: [AVCaptureDevice.DeviceType.builtInWideAngleCamera], mediaType: AVMediaType.video, position: AVCaptureDevice.Position.unspecified)
    }
    
    var videoInput: AVCaptureDeviceInput?
    var videoOutput = AVCaptureVideoDataOutput()
    var photoOutput = AVCapturePhotoOutput()
    
    func getPreviewLayer() -> AVCaptureVideoPreviewLayer? {
        guard let controller = self.controller else {
            return nil
        }
        
        let previewLayer = AVCaptureVideoPreviewLayer(session: self.session)
        previewLayer.frame = controller.view.bounds
        previewLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        return previewLayer
        
    }
    
    func captureStillImage() {
        if let delegate = self.delegate {
            delegate.stillImageCaptured(camera: self, image: UIImage())
        }
    }
    
    func update() {
       recycleDevice()
        do {
            
            let input = try AVCaptureDeviceInput(device: device)
            guard self.session.canAddInput(input) else {
                return
            }
            guard self.session.canAddOutput(self.videoOutput) else {
                return
            }
            guard self.session.canAddOutput(self.photoOutput) else {
                return
            }
            self.videoInput = input
            self.session.addInput(input)
            self.session.addOutput(self.videoOutput)
            self.session.addOutput(self.photoOutput)
            self.session.commitConfiguration()
            self.session.startRunning()
        } catch {
            print("Error linking device to AVInput !!!")
            return
            
        }
        
    }
    
}
// MARK: CaptureDevice Handling

private extension Camera {
    func getNewInputDevice() -> AVCaptureDeviceInput? {
        do {
            guard let device = getDevice(with: self.position == .front ? AVCaptureDevice.Position.front : AVCaptureDevice.Position.back) else {
                return nil
            }
            let input = try AVCaptureDeviceInput(device: device)
            return input
        } catch {
            return nil
        }
    }
    
    func recycleDevice() {
        for oldInput in self.session.inputs {
            self.session.removeInput(oldInput)
        }
        for oldOutput in self.session.outputs {
            self.session.removeOutput(oldOutput)
        }
    }
    private func getDevice(with position:
        AVCaptureDevice.Position) -> AVCaptureDevice? {
        guard let discoverySession = self.discoverySession
            else {
                return nil
        }
        for device in discoverySession.devices {
            if device.position == position {
                return device
            }
        }
        
        return nil
    }
}
















