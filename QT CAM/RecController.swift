//
//  ViewController.swift
//  QT CAM
//
//  Created by jason smellz on 10/7/19.
//  Copyright © 2019 jacob. All rights reserved.
//

import UIKit
import AVFoundation
import MediaPlayer

class RecController: NSObject, AVCapturePhotoCaptureDelegate {
    
    // AV Capture
    var captureSession: AVCaptureSession!
    var stillImageOutput: AVCapturePhotoOutput!
    var videoPreviewLayer: AVCaptureVideoPreviewLayer!
    var camera: AVCaptureDevice!
    
    // UI
//    var flipButton: UIButton!
//    var flashButton: UIButton!
    var currentImage: UIImage!
    
    // logic
    var backCamera: Bool = true
    var flash: Bool = false
    
    var container: ContainerViewController!
    
    var timer: Timer!
    var timerIsActive = false
    var time: Int = 0
    
    func cleanup() {
        self.captureSession.stopRunning()
        container.qtView.previewView.layer.sublayers = nil
    }
    
}

extension RecController {
    
    // toggle camera direction
    @objc func flipCameraView() {
        if backCamera {
            backCamera = false
            setupCamera()
        } else {
            backCamera = true
            setupCamera()
        }
    }
    
    @objc func takePhoto() {
        
        // deal with flash
        handleFlash()
        
        // capture photo
        let settings = AVCapturePhotoSettings(format: [AVVideoCodecKey: AVVideoCodecType.jpeg])
        stillImageOutput.capturePhoto(with: settings, delegate: self)
    }
    
    func takePhotoWithTimer() {
        timerIsActive = true
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(timerAction), userInfo: nil, repeats: true)
        
    }
    
    @objc func timerAction() {
        
        print("time", time)
        container.qtView.rightLabel.text = (10 - time).description
        time += 1
        
        guard 10 - time == 0 else {return}
        
        // stop the timer
        timer.invalidate()
        timerIsActive = false 
        time = 0
        
        takePhoto()
        
    }
    
    // deal with flash
    func handleFlash() {
        
        if camera.hasTorch {
            do {
                try camera.lockForConfiguration()
           
                if flash && backCamera {
                    camera.torchMode = .on
                } else {
                    camera.torchMode = .off
                }
                
                camera.unlockForConfiguration()
            } catch {
                print("Torch could not be used")
            }
        } else {
            print("Torch is not available")
        }
    }
}

// camera setup
    
extension RecController {
    
    func setupCamera() {
        
        captureSession = AVCaptureSession()
        captureSession.sessionPreset = .medium
        
        // which camera direction
        
        if backCamera {
            
            // back
            guard let device = AVCaptureDevice.default(for: AVMediaType.video)
                else {
                    print("Unable to access back camera!")
                    return
            }
            camera = device
            
        } else {
            
            // front
            guard let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: AVMediaType.video, position: .front)
                else {
                    // if front camera not working use back
                    backCamera = true
                    return setupCamera()
            }
            camera = device
        }

        do {
            let input = try AVCaptureDeviceInput(device: camera)
            
            stillImageOutput = AVCapturePhotoOutput()
            
            if captureSession.canAddInput(input) && captureSession.canAddOutput(stillImageOutput) {
                captureSession.addInput(input)
                captureSession.addOutput(stillImageOutput)
                // setup live preview
                setupLivePreview()
            }
        }
        catch let error  {
            print("Error Unable to initialize back camera:  \(error.localizedDescription)")
        }
        
    }
    
    func setupLivePreview() {
        
        videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        
        videoPreviewLayer.videoGravity = .resizeAspect
        videoPreviewLayer.connection?.videoOrientation = .landscapeLeft
        container.qtView.previewView.layer.addSublayer(videoPreviewLayer)
        
        DispatchQueue.global(qos: .userInitiated).async { //[weak self] in
            
            self.captureSession.startRunning()
            
        }
        
        DispatchQueue.main.async {
            
            self.videoPreviewLayer.frame = self.container.qtView.previewView.bounds
        }
        
    }
    
    // when photo is taken
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        
        guard let imageData = photo.fileDataRepresentation()
            else { return }
        
        // captured image
        let capturedImage = UIImage(data: imageData)
        
        // woven grain
//        var grainImage = #imageLiteral(resourceName: "brush-strokes-paint-stock-picture-1925873")
        var grainImage = #imageLiteral(resourceName: "IMG_204")
        
        grainImage = UIImage(cgImage: grainImage.cgImage!, scale: 1.0, orientation: .left)

        // captured image size
        let imageSize = capturedImage?.size
        
        let rect = CGRect(x: 0, y: 0, width: imageSize!.width, height: imageSize!.height)
            let renderer = UIGraphicsImageRenderer(size: imageSize!)
            
        var result = renderer.image { ctx in
                // fill the background with white so that translucent colors get lighter
                UIColor.init(white: 0.6, alpha: 1).set()
                ctx.fill(rect)
                
                grainImage.draw(in: rect, blendMode: .normal, alpha: 0.4)
                capturedImage?.draw(in: rect, blendMode: .overlay, alpha: 1)
        }

        result = result.resizeWithWidth(width: 480)!
        
        //compression
        
        let compressData = result.jpegData(compressionQuality:1) //max value is 1.0 and minimum is 0.0
        let compressedImage = UIImage(data: compressData!)
        compressedImage?.withSaturationAdjustment(byVal: 5)
        
        // save image
        guard let image = compressedImage as? UIImage else {return print("image not UIImage")}
        container.savePhotoLocally(image)
    
    }
    
}

