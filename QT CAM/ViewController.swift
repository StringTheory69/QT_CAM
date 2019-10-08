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
    
    var captureSession: AVCaptureSession!
    var stillImageOutput: AVCapturePhotoOutput!
    var videoPreviewLayer: AVCaptureVideoPreviewLayer!
    var previewView: UIView!
    var takePhotoButton: UIButton!
    var backCamera: Bool = true
    var flash: Bool = true
    var savedImageView: UIImageView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .black
        
        previewView = UIView()
        previewView.backgroundColor = .red
        previewView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(previewView)
        previewView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        previewView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        previewView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        previewView.heightAnchor.constraint(equalTo: view.widthAnchor, multiplier: 4/3).isActive = true
        
        // transparent view for formatting takePhotoButton
        let formatter = UILayoutGuide()
        self.view.addLayoutGuide(formatter)
        formatter.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        formatter.topAnchor.constraint(equalTo: previewView.bottomAnchor).isActive = true
        formatter.leadingAnchor.constraint(equalTo:view.leadingAnchor).isActive = true
        formatter.trailingAnchor.constraint(equalTo:view.trailingAnchor).isActive = true
        
        takePhotoButton = UIButton()
        takePhotoButton.backgroundColor = .red
        takePhotoButton.translatesAutoresizingMaskIntoConstraints = false
        takePhotoButton.addTarget(self, action: #selector(takePhoto), for: .touchUpInside)
        view.addSubview(takePhotoButton)
        takePhotoButton.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 1/12).isActive = true
        takePhotoButton.widthAnchor.constraint(equalTo: view.heightAnchor, multiplier: 1/12).isActive = true
        takePhotoButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        takePhotoButton.centerYAnchor.constraint(equalTo: formatter.centerYAnchor).isActive = true

    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        takePhotoButton.layer.masksToBounds = true
        takePhotoButton.layer.cornerRadius = takePhotoButton.frame.height/2
    }
    
    @objc func takePhoto() {
        
        let settings = AVCapturePhotoSettings(format: [AVVideoCodecKey: AVVideoCodecType.jpeg])
        stillImageOutput.capturePhoto(with: settings, delegate: self)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // Setup your camera here...
        captureSession = AVCaptureSession()
        captureSession.sessionPreset = .medium
        
        guard let camera = AVCaptureDevice.default(for: AVMediaType.video)
            else {
                print("Unable to access back camera!")
                return
        }
        

//        guard let camera = AVCaptureDevice.default(.builtInWideAngleCamera, for: AVMediaType.video, position: .front)
//                else {
//                    guard let camera = AVCaptureDevice.default(for: AVMediaType.video)
//                        else {
//                            print("Unable to access back camera!")
//                            return
//                    }
//            }
//
//
    
        
        do {
            let input = try AVCaptureDeviceInput(device: camera)
            
            stillImageOutput = AVCapturePhotoOutput()
            
            
            if captureSession.canAddInput(input) && captureSession.canAddOutput(stillImageOutput) {
                captureSession.addInput(input)
                captureSession.addOutput(stillImageOutput)
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
        
        //Step12
        
        DispatchQueue.global(qos: .userInitiated).async { //[weak self] in
            self.captureSession.startRunning()
            //Step 13
        }
        
        DispatchQueue.main.async {
            self.videoPreviewLayer.frame = self.previewView.bounds
        }
    }
    
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        
        guard let imageData = photo.fileDataRepresentation()
            else { return }
        
        var image = UIImage(data: imageData)
        
        let topImage = #imageLiteral(resourceName: "70716658-old-raw-canvas-texture-seamless-abstract-background")
        
        // TODO : change with orientation
        let newSize = image?.size // set this to what you need
        UIGraphicsBeginImageContextWithOptions(newSize!, false, 0.0)

        topImage.draw(in: CGRect(origin: .zero, size: newSize!), blendMode: .softLight, alpha: 0.5)

        image!.draw(in: CGRect(origin: .zero, size: newSize!), blendMode: .multiply, alpha: 1)
//
        var newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        newImage = newImage?.resizeWithWidth(width: 480)!
        
        let compressData = newImage?.jpegData(compressionQuality:1) //max value is 1.0 and minimum is 0.0
        newImage = UIImage(data: compressData!)
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "previewVC") as! ImagePreviewViewController
        controller.image = newImage
        self.present(controller, animated: true, completion: nil)
    

    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.captureSession.stopRunning()
    }
    
}


extension UIImage {
    func resizeWithPercent(percentage: CGFloat) -> UIImage? {
        let imageView = UIImageView(frame: CGRect(origin: .zero, size: CGSize(width: size.width * percentage, height: size.height * percentage)))
        imageView.contentMode = .scaleAspectFit
        imageView.image = self
        UIGraphicsBeginImageContextWithOptions(imageView.bounds.size, false, scale)
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        imageView.layer.render(in: context)
        guard let result = UIGraphicsGetImageFromCurrentImageContext() else { return nil }
        UIGraphicsEndImageContext()
        return result
    }
    func resizeWithWidth(width: CGFloat) -> UIImage? {
        let imageView = UIImageView(frame: CGRect(origin: .zero, size: CGSize(width: width, height: CGFloat(ceil(width/size.width * size.height)))))
        imageView.contentMode = .scaleAspectFit
        imageView.image = self
        UIGraphicsBeginImageContextWithOptions(imageView.bounds.size, false, scale)
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        imageView.layer.render(in: context)
        guard let result = UIGraphicsGetImageFromCurrentImageContext() else { return nil }
        UIGraphicsEndImageContext()
        return result
    }
}
