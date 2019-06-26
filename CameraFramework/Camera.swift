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
    
    func getPreviewLayer() -> AVCaptureVideoPreviewLayer? {
        guard let controller = self.controller else {
            return nil
        }
        
        let previewLayer = AVCaptureVideoPreviewLayer(session: self.session)
        previewLayer.frame = controller.view.bounds
        previewLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        return previewLayer
        
    }
    
    func update() {
        if let currentInput = self.videoInput {
            self.session.removeInput(currentInput)
            self.session.removeOutput(self.videoOutput)
        }
        do {
            guard let device = getDevice(with: self.position == .front ? AVCaptureDevice.Position.front : AVCaptureDevice.Position.back) else {
                return
            }
            let input = try AVCaptureDeviceInput(device: device)
            if self.session.canAddInput(input) &&
                self.session.canAddOutput(self.videoOutput)
            {
                self.videoInput = input
                self.session.addOutput(self.videoOutput)
                self.session.commitConfiguration()
                self.session.startRunning()
            }
        } catch {
            print("Error linking device to AVInput !!!")
            return
            
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
