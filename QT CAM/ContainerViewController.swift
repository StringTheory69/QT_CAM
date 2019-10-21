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
    var blackView: UIView!
    var topConstraint: NSLayoutConstraint!
    var leftLabel: UILabel!
    var rightLabel: UILabel!
    var changeModeButton: UIButton!

    var savedImages: [UIImage] = [] {
        didSet {
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
        
        blackView = UIView()
        blackView.alpha = 0.0
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
        leftLabel.backgroundColor = .white
        leftLabel.translatesAutoresizingMaskIntoConstraints = false
        view.insertSubview(leftLabel, belowSubview: blackView)
//        leftLabel.heightAnchor.constraint(equalTo: previewView.heightAnchor, multiplier: 0.39).isActive = true
        leftLabel.leadingAnchor.constraint(equalTo: previewView.leadingAnchor, constant: 20).isActive = true
        
        leftLabel.topAnchor.constraint(equalTo: previewView.topAnchor, constant: 20).isActive = true
        
        rightLabel = UILabel()
        rightLabel.text = "1"
        rightLabel.text = String(savedImages.count)
        rightLabel.backgroundColor = .white
        rightLabel.translatesAutoresizingMaskIntoConstraints = false
        view.insertSubview(rightLabel, belowSubview: blackView)
        //        leftLabel.heightAnchor.constraint(equalTo: previewView.heightAnchor, multiplier: 0.39).isActive = true
        rightLabel.trailingAnchor.constraint(equalTo: previewView.trailingAnchor, constant: -20).isActive = true
        
        rightLabel.topAnchor.constraint(equalTo: previewView.topAnchor, constant: 20).isActive = true
        
        
        changeModeButton = UIButton()
        changeModeButton.setTitle("SWITCH MODE", for: .normal)
        changeModeButton.setTitleColor(.white, for: .normal)
        changeModeButton.backgroundColor = .red
        changeModeButton.addTarget(self, action: #selector(changeMode), for: .touchUpInside)
        changeModeButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(changeModeButton)
        changeModeButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
//        changeModeButton.widthAnchor.constraint(equalToConstant: 200).isActive = true
        changeModeButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -100).isActive = true
        
        changeModeButton.topAnchor.constraint(equalTo: view.topAnchor, constant: 20).isActive = true
        
    }
    
    @objc func volumeChanged(notification: NSNotification) {
        if let userInfo = notification.userInfo {
            
            if let newVolumeValue = userInfo["AVSystemController_AudioVolumeNotificationParameter"]   as? Float {
                print("NEW VOLUME", newVolumeValue)
                
                volumeValue = newVolumeValue
            }
            
            if let volumeChangeType = userInfo["AVSystemController_AudioVolumeChangeReasonNotificationParameter"] as? String {
                
                guard volumeChangeType == "ExplicitVolumeChange" else {return}
                
                switch currentMode {
                case .play: do {
                    
                    // if volume increase scroll right else if decrease scroll left

                    previewView.image = playController.changePhoto(volumeIncrease)
                    
                    }
                // timer
                case .timer: do {
                    
                    // if volume increase then start timer and then take photo
                    guard volumeIncrease == true else {return}
                    
                    guard savedImages.count < 30 else {return print("images full")}
                    recController.takePhotoWithTimer()
                    
                    }
                
                // rec
                default: do {
                
                    // if volume increase then take photo
                    guard volumeIncrease == true else {return}
                    // check if image array < 30
                    guard savedImages.count < 30 else {return print("images full")}
                    recController.takePhoto()
                    
                    }
                }
                
                
            }
        }
    }
    
    @objc func changeMode() {
        
        switch currentMode {
        case .play: do {
            
            // change to timer mode
            rightLabel.text = String(savedImages.count)
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
            
            // change to play mode

            recController.cleanup()
            savedImages = persistentStorage.fetchData()
            print("IMAGES", savedImages)
            leftLabel.text = "PLAY"
            if savedImages.count >= 0 { rightLabel.text = "1" } else { rightLabel.text = "0" }
            previewView.image = playController.setup(savedImages)
            currentMode = .play
            print("PLAY")
            }
        }
        
    }

}

enum Mode {
    case rec
    case play
    case timer
}
