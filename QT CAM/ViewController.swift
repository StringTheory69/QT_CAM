//
//  ViewController.swift
//  QT CAM
//
//  Created by jason smellz on 10/7/19.
//  Copyright © 2019 jacob. All rights reserved.
//

import UIKit
import AVFoundation
class CameraViewController: UIViewController, AVCapturePhotoCaptureDelegate {
    
    // AV Capture
    var captureSession: AVCaptureSession!
    var stillImageOutput: AVCapturePhotoOutput!
    var videoPreviewLayer: AVCaptureVideoPreviewLayer!
    var camera: AVCaptureDevice!
    
    // UI
    var previewView: UIView!
    var takePhotoButton: UIButton!
    var savedImageView: UIImageView!
    var flipButton: UIButton!
    var flashButton: UIButton!
    
    // logic
    var backCamera: Bool = true
    var flash: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Setup views
        setupViews()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // Setup camera
        setupCamera()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // round takePhotoButton edges
        takePhotoButton.layer.masksToBounds = true
        takePhotoButton.layer.cornerRadius = takePhotoButton.frame.height/2
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // cleanup
        self.captureSession.stopRunning()
    }
    
}

// setup views
extension CameraViewController {
    
    func setupViews() {
        
        view.backgroundColor = .black
        
        previewView = UIView()
        previewView.backgroundColor = .black
        previewView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(previewView)
        
        previewView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        previewView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        previewView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        previewView.heightAnchor.constraint(equalTo: view.widthAnchor, multiplier: 4/3).isActive = true
        
        // transparent view for formatting buttons
        let bottomFormatter = UILayoutGuide()
        self.view.addLayoutGuide(bottomFormatter)
        
        bottomFormatter.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        bottomFormatter.topAnchor.constraint(equalTo: previewView.bottomAnchor).isActive = true
        bottomFormatter.leadingAnchor.constraint(equalTo:view.leadingAnchor).isActive = true
        bottomFormatter.trailingAnchor.constraint(equalTo:view.trailingAnchor).isActive = true
        
        let topFormatter = UILayoutGuide()
        self.view.addLayoutGuide(topFormatter)
        
        topFormatter.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        topFormatter.bottomAnchor.constraint(equalTo: previewView.topAnchor).isActive = true
        topFormatter.leadingAnchor.constraint(equalTo:view.leadingAnchor).isActive = true
        topFormatter.trailingAnchor.constraint(equalTo:view.trailingAnchor).isActive = true
        
        takePhotoButton = UIButton()
        takePhotoButton.backgroundColor = .red
        takePhotoButton.translatesAutoresizingMaskIntoConstraints = false
        takePhotoButton.addTarget(self, action: #selector(takePhoto), for: .touchUpInside)
        view.addSubview(takePhotoButton)
        
        takePhotoButton.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 1/12).isActive = true
        takePhotoButton.widthAnchor.constraint(equalTo: view.heightAnchor, multiplier: 1/12).isActive = true
        takePhotoButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        takePhotoButton.centerYAnchor.constraint(equalTo: bottomFormatter.centerYAnchor).isActive = true
        
        flipButton = UIButton()
//        flipButton.setTitle("FLIP", for: .normal)
        flipButton.setImage(#imageLiteral(resourceName: "noun_Flip Camera_390580"), for: .normal)
        flipButton.setTitleColor(.white, for: .normal)
        flipButton.translatesAutoresizingMaskIntoConstraints = false
        flipButton.addTarget(self, action: #selector(flipCameraView), for: .touchUpInside)
        view.addSubview(flipButton)
        
        flipButton.leadingAnchor.constraint(equalTo: takePhotoButton.trailingAnchor).isActive = true
        flipButton.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        flipButton.centerYAnchor.constraint(equalTo: bottomFormatter.centerYAnchor).isActive = true
        
        flashButton = UIButton()
//        flashButton.setTitle("FLASH OFF", for: .normal)
        flashButton.setImage(#imageLiteral(resourceName: "noun_flash off_552195"), for: .normal)
        flashButton.setTitleColor(.white, for: .normal)
        flashButton.translatesAutoresizingMaskIntoConstraints = false
        flashButton.addTarget(self, action: #selector(flashButtonAction), for: .touchUpInside)
        view.addSubview(flashButton)
        
        flashButton.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        flashButton.trailingAnchor.constraint(equalTo: takePhotoButton.leadingAnchor).isActive = true
        flashButton.centerYAnchor.constraint(equalTo: bottomFormatter.centerYAnchor).isActive = true
    }
    
}

// UX functions

extension CameraViewController {
    
    // toggle flash
    @objc func flashButtonAction() {
        if !flash {
//            flashButton.setTitle("FLASH ON", for: .normal)
            flashButton.setImage(#imageLiteral(resourceName: "noun_flash_552194"), for: .normal)
            flash = true
        } else {
//            flashButton.setTitle("FLASH OFF", for: .normal)
            flashButton.setImage(#imageLiteral(resourceName: "noun_flash off_552195"), for: .normal)
            flash = false
        }
    }
    
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
    
extension CameraViewController {
    
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
        videoPreviewLayer.connection?.videoOrientation = .portrait
        previewView.layer.addSublayer(videoPreviewLayer)
        
        DispatchQueue.global(qos: .userInitiated).async { //[weak self] in
            self.captureSession.startRunning()
            
        }
        
        DispatchQueue.main.async {
            self.videoPreviewLayer.frame = self.previewView.bounds
        }
        
    }
    
    // when photo is taken
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        
        guard let imageData = photo.fileDataRepresentation()
            else { return }
        
        // captured image
        let capturedImage = UIImage(data: imageData)
        
        // woven grain
        let grainImage = #imageLiteral(resourceName: "70716658-old-raw-canvas-texture-seamless-abstract-background")
        
        // captured image size
        let imageSize = capturedImage?.size
        
        // begin blend
        UIGraphicsBeginImageContextWithOptions(imageSize!, false, 0.0)

        // grain image blend
        grainImage.draw(in: CGRect(origin: .zero, size: imageSize!), blendMode: .softLight, alpha: 0.5)
        
        // captured image blend
        capturedImage!.draw(in: CGRect(origin: .zero, size: imageSize!), blendMode: .multiply, alpha: 1)

        // end blend
        // processed image
        var processedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        processedImage = processedImage?.resizeWithWidth(width: 960)!
        
        //compression
        
        let compressData = processedImage?.jpegData(compressionQuality:1) //max value is 1.0 and minimum is 0.0
        let compressedImage = UIImage(data: compressData!)
        
        // initialize image save view
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "previewVC") as! ImagePreviewViewController
        
        // pass image to controller
        controller.image = compressedImage
        
        // present controller
        self.present(controller, animated: true, completion: nil)
    
    }
    
}
