//
//  Camera.swift
//  CameraFramework
//
//  Created by Daval Cato on 6/23/19.
//  Copyright © 2019 Daval Cato. All rights reserved.
//

import UIKit
import AVFoundation


class Camera: NSObject {
    
    var controller: CameraViewController?
    
    required init(with controller: CameraViewController) {
        self.controller = controller
    }
    
    fileprivate var session = AVCaptureSession()
    fileprivate var discoverySession: AVCaptureDevice.DiscoverySession? {
        return AVCaptureDevice.DiscoverySession(deviceTypes: [AVCaptureDevice.DeviceType.builtInWideAngleCamera], mediaType: AVMediaType.video, position: AVCaptureDevice.Position.unspecified)
    }
    
    var videoInput: AVCaptureDeviceInput?
    var videoOutput: AVCaptureVideoDataOutput()
    
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
    }

}
