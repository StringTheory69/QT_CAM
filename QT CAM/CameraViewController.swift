//
//  ViewController.swift
//  QT CAM
//
//  Created by jason smellz on 10/7/19.
//  Copyright © 2019 jacob. All rights reserved.
//

import UIKit
import AVFoundation
import NotificationCenter
import MediaPlayer

class CameraViewController: UIViewController, AVCapturePhotoCaptureDelegate {
    
    // AV Capture
    var captureSession: AVCaptureSession!
    var stillImageOutput: AVCapturePhotoOutput!
    var videoPreviewLayer: AVCaptureVideoPreviewLayer!
    var camera: AVCaptureDevice!
    
    // UI
    var previewView: UIView!
    var cameraImageView: UIImageView!
    var imageView: UIImageView!
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
        let volumeView = MPVolumeView(frame: CGRect(x: -CGFloat.greatestFiniteMagnitude, y: 0.0, width: 0.0, height: 0.0))
        self.view.addSubview(volumeView)
        NotificationCenter.default.addObserver(self, selector: #selector(volumeChanged(notification:)), name: NSNotification.Name(rawValue: "AVSystemController_SystemVolumeDidChangeNotification"), object: nil)
        setupViews()
    }
    
    
    @objc func volumeChanged(notification: NSNotification) {
        
        if let userInfo = notification.userInfo {
            if let volumeChangeType = userInfo["AVSystemController_AudioVolumeChangeReasonNotificationParameter"] as? String {
                if volumeChangeType == "ExplicitVolumeChange" {
                    // your code goes here
                    takePhoto()
                }
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // Setup camera
        setupCamera()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // round takePhotoButton edges
//        takePhotoButton.layer.masksToBounds = true
//        takePhotoButton.layer.cornerRadius = takePhotoButton.frame.height/2
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
        
        cameraImageView = UIImageView()
        cameraImageView.image = #imageLiteral(resourceName: "FullSizeRenderMask")
        //        previewView.backgroundColor = .black
//        cameraImageView.backgroundColor = UIColor.init(red: 1, green: 0, blue: 0, alpha: 0.5)
        cameraImageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(cameraImageView)
        
        //        previewView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        //        previewView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        cameraImageView.heightAnchor.constraint(equalTo: view.heightAnchor).isActive = true
        cameraImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        cameraImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        cameraImageView.widthAnchor.constraint(equalTo: view.heightAnchor, multiplier: 1.78).isActive = true
        
        // preview view
        
        previewView = UIView()
//        previewView.backgroundColor = .black
        previewView.backgroundColor = UIColor.init(red: 1, green: 0, blue: 0, alpha: 0.2)
        previewView.translatesAutoresizingMaskIntoConstraints = false
        view.insertSubview(previewView, belowSubview: cameraImageView)
        
//        previewView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
//        previewView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        previewView.heightAnchor.constraint(equalTo: cameraImageView.heightAnchor, multiplier: 0.39).isActive = true
        previewView.leadingAnchor.constraint(equalTo: cameraImageView.leadingAnchor, constant: view.frame.height*1.78*0.32).isActive = true
        
        previewView.topAnchor.constraint(equalTo: cameraImageView.topAnchor, constant: view.frame.height*0.27).isActive = true
        previewView.widthAnchor.constraint(equalTo: previewView.heightAnchor, multiplier: 4/3).isActive = true
        
        imageView = UIImageView()
        imageView.backgroundColor = .clear
        imageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(imageView)
        
        imageView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        imageView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        imageView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        imageView.heightAnchor.constraint(equalTo: view.widthAnchor, multiplier: 4/3).isActive = true
        
        // transparent view for formatting buttons
        let rightFormatter = UILayoutGuide()
        self.view.addLayoutGuide(rightFormatter)
        
        rightFormatter.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        rightFormatter.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        rightFormatter.leadingAnchor.constraint(equalTo:previewView.trailingAnchor).isActive = true
        rightFormatter.trailingAnchor.constraint(equalTo:view.trailingAnchor).isActive = true
        
        let leftFormatter = UILayoutGuide()
        self.view.addLayoutGuide(leftFormatter)
        
        leftFormatter.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        leftFormatter.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        leftFormatter.leadingAnchor.constraint(equalTo:view.leadingAnchor).isActive = true
        leftFormatter.trailingAnchor.constraint(equalTo:cameraImageView.leadingAnchor).isActive = true
        
//        takePhotoButton = UIButton()
//        takePhotoButton.backgroundColor = .red
//        takePhotoButton.translatesAutoresizingMaskIntoConstraints = false
//        takePhotoButton.addTarget(self, action: #selector(takePhoto), for: .touchUpInside)
//        view.addSubview(takePhotoButton)
//
//        takePhotoButton.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 1/7).isActive = true
//        takePhotoButton.widthAnchor.constraint(equalTo: view.heightAnchor, multiplier: 1/7).isActive = true
//        takePhotoButton.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
//        takePhotoButton.centerXAnchor.constraint(equalTo: rightFormatter.centerXAnchor).isActive = true
        
        flashButton = UIButton()
//        flashButton.setTitle("FLASH OFF", for: .normal)
        flashButton.setImage(#imageLiteral(resourceName: "noun_flash off_552195"), for: .normal)
        flashButton.setTitleColor(.white, for: .normal)
        flashButton.translatesAutoresizingMaskIntoConstraints = false
        flashButton.addTarget(self, action: #selector(flashButtonAction), for: .touchUpInside)
        view.addSubview(flashButton)
        
        flashButton.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        flashButton.trailingAnchor.constraint(equalTo: cameraImageView.leadingAnchor).isActive = true
        flashButton.centerYAnchor.constraint(equalTo: rightFormatter.centerYAnchor).isActive = true
        
        flipButton = UIButton()
        //        flipButton.setTitle("FLIP", for: .normal)
        flipButton.setImage(#imageLiteral(resourceName: "noun_Flip Camera_390580"), for: .normal)
        flipButton.setTitleColor(.white, for: .normal)
        flipButton.translatesAutoresizingMaskIntoConstraints = false
        flipButton.addTarget(self, action: #selector(flipCameraView), for: .touchUpInside)
        view.addSubview(flipButton)
        
        flipButton.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        flipButton.trailingAnchor.constraint(equalTo: cameraImageView.leadingAnchor).isActive = true
        flipButton.bottomAnchor.constraint(equalTo: flashButton.topAnchor, constant: -20).isActive = true
        
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
        videoPreviewLayer.connection?.videoOrientation = .landscapeLeft
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
//        var grainImage = #imageLiteral(resourceName: "brush-strokes-paint-stock-picture-1925873")
        var grainImage = #imageLiteral(resourceName: "IMG_204")
        
        grainImage = UIImage(cgImage: grainImage.cgImage!, scale: 1.0, orientation: .left)

        // captured image size
        let imageSize = capturedImage?.size
        
//        if let img = grainImage, let img2 = capturedImage {
        let rect = CGRect(x: 0, y: 0, width: imageSize!.width, height: imageSize!.height)
            let renderer = UIGraphicsImageRenderer(size: imageSize!)
            
        var result = renderer.image { ctx in
                // fill the background with white so that translucent colors get lighter
//                UIColor.white.set()
                ctx.fill(rect)
                
                grainImage.draw(in: rect, blendMode: .normal, alpha: 1)
                capturedImage?.draw(in: rect, blendMode: .overlay, alpha: 1)
            }
//        }
        
//        // begin blend
//        UIGraphicsBeginImageContextWithOptions(imageSize!, false, 0.0)
//
//        // grain image blend
//        grainImage.draw(in: CGRect(origin: .zero, size: imageSize!), blendMode: .normal, alpha: 1)
//
//        // captured image blend
//        capturedImage!.draw(in: CGRect(origin: .zero, size: imageSize!), blendMode: .overlay, alpha: 1)
//
//        // end blend
//        // processed image
//        var processedImage = UIGraphicsGetImageFromCurrentImageContext()
//        UIGraphicsEndImageContext()

        result = result.resizeWithWidth(width: 480)!
        
        //compression
        
        let compressData = result.jpegData(compressionQuality:1) //max value is 1.0 and minimum is 0.0
        let compressedImage = UIImage(data: compressData!)
        compressedImage?.withSaturationAdjustment(byVal: 5)
        // initialize image save view
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "previewVC") as! ImagePreviewViewController
        
        // pass image to controller
        controller.backCamera = backCamera
        controller.image = compressedImage
        
        // present controller
        self.present(controller, animated: false, completion: nil)
    
    }
    
}

extension UIImage {
    
    func withSaturationAdjustment(byVal: CGFloat) -> UIImage {
        guard let cgImage = self.cgImage else { return self }
        guard let filter = CIFilter(name: "CIColorControls") else { return self }
        filter.setValue(CIImage(cgImage: cgImage), forKey: kCIInputImageKey)
        filter.setValue(byVal, forKey: kCIInputSaturationKey)
        guard let result = filter.value(forKey: kCIOutputImageKey) as? CIImage else { return self }
        guard let newCgImage = CIContext(options: nil).createCGImage(result, from: result.extent) else { return self }
        return UIImage(cgImage: newCgImage, scale: UIScreen.main.scale, orientation: imageOrientation)
    }
    
}
