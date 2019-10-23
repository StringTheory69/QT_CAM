//
//  TabBarController.swift
//  QT CAM
//
//  Created by jason smellz on 10/13/19.
//  Copyright © 2019 jacob. All rights reserved.
//

import UIKit
import MediaPlayer
import NotificationCenter

class ContainerViewController: UIViewController {
    
    let persistentStorage = PersistentStorage()
    
    // UI
    var previewView: UIImageView!
    var cameraImageView: UIImageView!
    var blackView: UIImageView!
    var topConstraint:
    NSLayoutConstraint!
    var leftLabel: UILabel!
    var rightLabel: UILabel!
    var saveButton: UIButton!
    var deleteButton: UIButton!
    var changeModeButton: UIButton!

    var savedImages: [SavedImage] = [] {
        didSet {
            print(savedImages)
            guard savedImages.count >= 30 else {return}
            imagesFull = true
        }
    }
    
    var imagesFull: Bool = false
    
    var volumeValue: Float = 0 {
        willSet (newVal) {
            if newVal > volumeValue || newVal == 1 {
                volumeIncrease = true
            } else {
                volumeIncrease = false
            }
        }
    }
    
    var volumeIncrease: Bool!
    
    var recController = RecController()
    var playController = PlayController()

    // always begin on rec controller
    var currentMode: Mode = .rec
    
    var animationActive = false
    
    var cacheCount = 0
    
    var font: UIFont!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var font = UIFont(name: "Old-School-Adventures", size: 20)
        
        recController.container = self
        playController.container = self
        
        let volumeView = MPVolumeView(frame: CGRect(x: -CGFloat.greatestFiniteMagnitude, y: 0.0, width: 0.0, height: 0.0))
        self.view.addSubview(volumeView)
        NotificationCenter.default.addObserver(self, selector: #selector(volumeChanged(notification:)), name: NSNotification.Name(rawValue: "AVSystemController_SystemVolumeDidChangeNotification"), object: nil)
        savedImages = persistentStorage.fetchData()
        setupViews()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        recController.setupCamera()
        
//        for family in UIFont.familyNames.sorted() {
//            let names = UIFont.fontNames(forFamilyName: family)
//            print("Family: \(family) Font names: \(names)")
//        }
    }
    
    func setupViews() {
        
        view.backgroundColor = .black
        
        cameraImageView = UIImageView()
        cameraImageView.image = #imageLiteral(resourceName: "FullSizeRenderMask")
        cameraImageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(cameraImageView)
        cameraImageView.heightAnchor.constraint(equalTo: view.heightAnchor).isActive = true
        cameraImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        cameraImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        cameraImageView.widthAnchor.constraint(equalTo: view.heightAnchor, multiplier: 1.78).isActive = true
        
        // preview view
        
        previewView = UIImageView()
        previewView.translatesAutoresizingMaskIntoConstraints = false
        view.insertSubview(previewView, belowSubview: cameraImageView)
        previewView.heightAnchor.constraint(equalTo: cameraImageView.heightAnchor, multiplier: 0.39).isActive = true
        previewView.leadingAnchor.constraint(equalTo: cameraImageView.leadingAnchor, constant: view.frame.height*1.78*0.32).isActive = true
        
        previewView.topAnchor.constraint(equalTo: cameraImageView.topAnchor, constant: view.frame.height*0.27).isActive = true
        previewView.widthAnchor.constraint(equalTo: previewView.heightAnchor, multiplier: 4/3).isActive = true
        
        blackView = UIImageView()
        blackView.alpha = 1
        blackView.isHidden = true
        blackView.backgroundColor = .black
        blackView.translatesAutoresizingMaskIntoConstraints = false
        view.insertSubview(blackView, belowSubview: cameraImageView)
        blackView.leadingAnchor.constraint(equalTo: previewView.leadingAnchor).isActive = true
        blackView.trailingAnchor.constraint(equalTo: previewView.trailingAnchor).isActive = true
        blackView.bottomAnchor.constraint(equalTo: previewView.bottomAnchor).isActive = true
        // Create the top constraint
        topConstraint = blackView.topAnchor.constraint(equalTo: previewView.topAnchor, constant: 0)
        // Activate top constaint
        NSLayoutConstraint.activate([
            topConstraint,
            ])
        
        leftLabel = UILabel()
        leftLabel.text = "REC"
        leftLabel.textColor = .white
        leftLabel.font = UIFont(name: "Old-School-Adventures", size: 12)
        leftLabel.backgroundColor = .clear
        leftLabel.translatesAutoresizingMaskIntoConstraints = false
        view.insertSubview(leftLabel, belowSubview: blackView)
//        leftLabel.heightAnchor.constraint(equalTo: previewView.heightAnchor, multiplier: 0.39).isActive = true
        leftLabel.leadingAnchor.constraint(equalTo: previewView.leadingAnchor, constant: 20).isActive = true
        
        leftLabel.topAnchor.constraint(equalTo: previewView.topAnchor, constant: 20).isActive = true
        
        rightLabel = UILabel()
        rightLabel.text = "1"
        rightLabel.text = String(savedImages.count)
        rightLabel.font = UIFont(name: "Old-School-Adventures", size: 12)
        cacheCount = savedImages.count
        rightLabel.textColor = .white
        rightLabel.backgroundColor = .clear
        rightLabel.translatesAutoresizingMaskIntoConstraints = false
        view.insertSubview(rightLabel, belowSubview: blackView)
        //        leftLabel.heightAnchor.constraint(equalTo: previewView.heightAnchor, multiplier: 0.39).isActive = true
        rightLabel.trailingAnchor.constraint(equalTo: previewView.trailingAnchor, constant: -20).isActive = true
        rightLabel.topAnchor.constraint(equalTo: previewView.topAnchor, constant: 20).isActive = true
        
        changeModeButton = UIButton()
//        changeModeButton.setTitle("SWITCH MODE", for: .normal)
//        changeModeButton.setTitleColor(.white, for: .normal)
        changeModeButton.backgroundColor = .red
        changeModeButton.addTarget(self, action: #selector(changeMode), for: .touchUpInside)
        changeModeButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(changeModeButton)
        changeModeButton.widthAnchor.constraint(equalToConstant: 300).isActive = true
        changeModeButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        changeModeButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0).isActive = true
        changeModeButton.topAnchor.constraint(equalTo: view.topAnchor, constant: 20).isActive = true
        
        saveButton = UIButton()
        saveButton.isHidden = true
        let quote = "Save"
        let font = UIFont(name: "Old-School-Adventures", size: 12)
        let attributes: [NSAttributedString.Key: Any] = [
            .font: font,
            .foregroundColor: UIColor.white,
        ]
        let attributedQuote = NSAttributedString(string: quote, attributes: attributes)
//        saveButton.setTitle("Save", for: .normal)
        saveButton.setAttributedTitle(attributedQuote, for: .normal)
        saveButton.setTitleColor(.white, for: .normal)
        saveButton.addTarget(self, action: #selector(savePhoto), for: .touchUpInside)
        saveButton.backgroundColor = .clear
        saveButton.translatesAutoresizingMaskIntoConstraints = false
        view.insertSubview(saveButton, belowSubview: blackView)
        //        leftLabel.heightAnchor.constraint(equalTo: previewView.heightAnchor, multiplier: 0.39).isActive = true
        saveButton.leadingAnchor.constraint(equalTo: previewView.leadingAnchor, constant: 20).isActive = true
        
        saveButton.bottomAnchor.constraint(equalTo: previewView.bottomAnchor, constant: -20).isActive = true
        
        deleteButton = UIButton()
        deleteButton.isHidden = true
        let delete = "Delete"
        let deleteText = NSAttributedString(string: delete, attributes: attributes)
        //        saveButton.setTitle("Save", for: .normal)
        deleteButton.setAttributedTitle(deleteText, for: .normal)
        deleteButton.addTarget(self, action: #selector(deletePhoto), for: .touchUpInside)
//        deleteButton.setTitle("Delete", for: .normal)
//        deleteButton.setTitleColor(.white, for: .normal)
        deleteButton.backgroundColor = .clear
        deleteButton.translatesAutoresizingMaskIntoConstraints = false
        view.insertSubview(deleteButton, belowSubview: blackView)
        //        leftLabel.heightAnchor.constraint(equalTo: previewView.heightAnchor, multiplier: 0.39).isActive = true
        deleteButton.trailingAnchor.constraint(equalTo: previewView.trailingAnchor, constant: -20).isActive = true
        deleteButton.bottomAnchor.constraint(equalTo: previewView.bottomAnchor, constant: -20).isActive = true
        
    }
    
    @objc func savePhoto() {
        
        let img = UIImage(cgImage: savedImages[playController.currentImage].image.cgImage!, scale: 1.0, orientation: .right)
        UIImageWriteToSavedPhotosAlbum(img, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
        
    }
    
    @objc func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        if let error = error {
            // we got back an error!
            let ac = UIAlertController(title: "Save error", message: error.localizedDescription, preferredStyle: .alert)
            
            ac.addAction(UIAlertAction(title: "OK", style: .default) { _ in
                //                self.close()
            })
            //            present(ac, animated: true)
            
        } else {
            //            let ac = UIAlertController(title: "Saved!", message: "Your altered image has been saved to your photos.", preferredStyle: .alert)
            //            ac.addAction(UIAlertAction(title: "OK", style: .default ){ _ in
            //                self.close()
            //            })
            //            present(ac, animated: true)
            //            self.close()
            self.animationActive = true
            playAnimation()
            
        }
    }
    
    @objc func deletePhoto() {
        let toDeletePath = savedImages[playController.currentImage].filePath
        blackView.isHidden = false
        persistentStorage.deleteData(toDeletePath!) { _ in
            playMode()
        }

    }
    
    @objc func volumeChanged(notification: NSNotification) {
        if let userInfo = notification.userInfo {
            
            if let newVolumeValue = userInfo["AVSystemController_AudioVolumeNotificationParameter"]   as? Float {
                print("NEW VOLUME", newVolumeValue)
                
                volumeValue = newVolumeValue
            }
            
            if let volumeChangeType = userInfo["AVSystemController_AudioVolumeChangeReasonNotificationParameter"] as? String {
                
                guard volumeChangeType == "ExplicitVolumeChange" else {return}
                guard animationActive == false else {return}

                switch currentMode {
                case .play: do {
                    
                    // if volume increase scroll right else if decrease scroll left
                    animationActive = true
                    playAnimation()
                    previewView.image = playController.changePhoto(volumeIncrease)
                    }
                // timer
                case .timer: do {
                    
                    // if volume increase then start timer and then take photo
                    guard volumeIncrease == true else {return}
                    
                    guard savedImages.count <= 30 else {return print("images full")}
                    
                    // timer is already going
                    guard recController.timerIsActive == false else {return print("timer is active")}
                    
                    recController.takePhotoWithTimer()
                    
                    }
                
                // rec
                default: do {
                    animationActive = true
                    blackView.isHidden = false
                    // if volume increase then take photo
                    guard volumeIncrease == true else {return}
                    // check if image array < 30
                    guard savedImages.count <= 30 else {return print("images full")}
                    recController.takePhoto()
                    
                    }
                }
            }
        }
    }
    
    func playMode() {
        recController.cleanup()
        savedImages = persistentStorage.fetchData()
        // change to play mode
        if savedImages.count != 0 {
            blackView.isHidden = false
            self.animationActive = true
            playAnimation()
        }
        print("IMAGES", savedImages)
        leftLabel.text = "PLAY"
        if savedImages.count == 0 {
            saveButton.isHidden = true
            deleteButton.isHidden = true
            rightLabel.text = "Null"
            previewView.image = UIImage()
        }
        else {
            saveButton.isHidden = false
            deleteButton.isHidden = false
            rightLabel.text = "1"
            previewView.image = playController.setup(savedImages)
        }
        
        currentMode = .play
        print("PLAY")
    }

    
    @objc func changeMode() {
        
        guard animationActive == false else {return}
        switch currentMode {
        case .play: do {
            
            // change to timer mode
            saveButton.isHidden = true
            deleteButton.isHidden = true
            self.topConstraint.constant = 0
            self.view.layoutIfNeeded()
            blackView.isHidden = true
            rightLabel.text = String(savedImages.count)
            cacheCount = savedImages.count
            leftLabel.text = "TIMER"
            recController.setupCamera()
            currentMode = .timer
            print("TIMER")
            }
        // timer
        case .timer: do {
            
            // change to rec mode
            leftLabel.text = "REC"
            currentMode = .rec
            print("REC")
            }
            
        // rec
        default: do {
            
            playMode()
        }
        }
    }
        
    
        
    @objc func playAnimation() {
        self.topConstraint.constant = 0
        self.view.layoutIfNeeded()
        topConstraint.constant = self.previewView.frame.height
        UIView.animate(withDuration: 4, animations: {
            self.view.layoutIfNeeded()
        }, completion: { _ in
            self.animationActive = false
        })
    }
    
    func saveImage(_ image: UIImage) {
        
        // for timer
        animationActive = true
        blackView.isHidden = false
        
        print("save image started")
        persistentStorage.saveData(image) { success in
            print("save image started 2")
            if success != false {
                recController.cleanup()
                
                let flippedImage = UIImage(cgImage: image.cgImage!, scale: 1.0, orientation: .right)
                self.previewView.image = flippedImage
                self.leftLabel.isHidden = true
                self.rightLabel.isHidden = true
                
                self.topConstraint.constant = 0
                self.view.layoutIfNeeded()
                topConstraint.constant = self.previewView.frame.height
                UIView.animate(withDuration: 4, animations: {
                    self.view.layoutIfNeeded()
                }, completion: { _ in
                    
                    Timer.scheduledTimer(withTimeInterval: 2, repeats: false, block: { (_) in
                        print("save image started 4")
                        DispatchQueue.main.async {
                            self.blackView.isHidden = true
                            self.blackView.image = UIImage()
                            self.cacheCount += 1
                            self.rightLabel.text = String(self.cacheCount)
                            self.leftLabel.isHidden = false
                            self.rightLabel.isHidden = false
                            self.animationActive = false
                            self.recController.setupCamera()
                        }
                    })

                })
                
//                Timer.scheduledTimer(withTimeInterval: 1, repeats: false, block: { (_) in
////                    self.blackView.isHidden = true
//                    print("save image started 3")
//                    DispatchQueue.main.async {
//                        let flippedImage = UIImage(cgImage: image.cgImage!, scale: 1.0, orientation: .right)
//                        self.blackView.image = flippedImage
//                    }
//
//
//                    Timer.scheduledTimer(withTimeInterval: 3, repeats: false, block: { (_) in
//                        print("save image started 4")
//                        DispatchQueue.main.async {
//                        self.blackView.isHidden = true
//                        self.blackView.image = UIImage()
//                        self.cacheCount += 1
//                        self.rightLabel.text = String(self.cacheCount)
//                        self.animationActive = false
//                        }
//                    })
//
//                })

            } else {
                print("FAILURE TO SAVE")
            }
            
        }
    }
        
}

enum Mode {
    case rec
    case play
    case timer
}
