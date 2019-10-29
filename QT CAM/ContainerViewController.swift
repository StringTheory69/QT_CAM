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
    
    // storage managment
    let persistentStorage = PersistentStorage()
    
    var imagePaths: [String] = [] {
        didSet {

            guard imagePaths.count >= 30 else {return}
            imagesFull = true
        }
    }
    
    var imagesFull: Bool = false
    
    // if first volume click is - volume : this doesn't work
    var volumeIncrease: Bool!
    
    var currentImage = 0
    
    var currentTutorialSlide = 1
    var tutorialActive = false
    
    var volumeValue: Float = 0 {
        willSet (newVal) {
            
            if newVal > volumeValue || newVal == 1 {
                volumeIncrease = true
            } else {
                volumeIncrease = false
            }
        }
    }
    
    lazy var recController: RecController = {
        let recController = RecController()
        recController.container = self
        return recController
    }()

    // always begin on rec controller
    var currentMode: Mode = .rec
    
    var animationActive = false
        
    lazy var qtView: QTView = {
        let qtView = QTView(frame: view.frame)
        return qtView
    }()
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(qtView)

        firstTime()
    
        NotificationCenter.default.addObserver(self, selector: #selector(volumeChanged(notification:)), name: NSNotification.Name(rawValue: "AVSystemController_SystemVolumeDidChangeNotification"), object: nil)

        // set button actions
        qtView.deleteButton.addTarget(self, action: #selector(deletePhoto), for: .touchUpInside)
        qtView.changeModeButton.addTarget(self, action: #selector(changeMode), for: .touchUpInside)
        qtView.saveButton.addTarget(self, action: #selector(savePhoto), for: .touchUpInside)
        qtView.popUpButton.addTarget(self, action: #selector(presentPopUpView), for: .touchUpInside)
        // data stuff
        persistentStorage.fetchPaths() { (paths, success) in
            if success == true {
                print("paths fetch success")
                imagePaths = paths
                qtView.rightLabel.text = imagePaths.count.description
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        
        qtView.leftLabel.text = "REC"
        recController.setupCamera()
        
    }
    
    func firstTime() {
        if !UserDefaults.standard.bool(forKey: "firstTime") {
            UserDefaults.standard.set(true, forKey: "firstTime")
            tutorialBegin()
        } else {
            print("this is not the first time")
        }
    }
    
}

// UX 

extension ContainerViewController {
    
    func attemptImageToPreviewView() {
        guard let image = persistentStorage.getImage(imagePaths[currentImage]) else {return errorAlert()}
        guard let flip = flipImage(image) else {return errorAlert()}
        qtView.previewView.image = flip
    }
    
    func volumeActions() {
    switch currentMode {
            
        case .tutorial: do {
            
            if volumeIncrease {
                currentTutorialSlide += 1
            } else {
                currentTutorialSlide -= 1
            }
            print(currentTutorialSlide, qtView.tutorialImages.count)

            guard currentTutorialSlide >= 1 else {
                currentTutorialSlide = 1
                return
            }
            
            guard currentTutorialSlide > qtView.tutorialImages.count else {return qtView.tutorialSlide(currentTutorialSlide)}
            tutorialEnd()
        }
            
        case .play: do {
            
            // if volume increase scroll right else if decrease scroll left
                animationActive = true
                playAnimation()
                changePhoto(advance: volumeIncrease)
                attemptImageToPreviewView()
            }
        // timer
        case .timer: do {
            
            // if volume increase then start timer and then take photo
            guard volumeIncrease == true else {return}
            
            guard imagePaths.count <= 30 else {return print("images full")}
            
            // timer is already going
            guard recController.timerIsActive == false else {return print("timer is active")}
            
            recController.takePhotoWithTimer()
            
            }
        
        // rec
        default: do {
            print("REC VOLUME")

            // if volume increase then take photo
            guard volumeIncrease == true else {return}
            animationActive = true
            qtView.blackView.isHidden = false
            // check if image array < 30
            guard imagePaths.count <= 30 else {return print("images full")}
            recController.takePhoto()
            
            }
        }
    }
    
    // volume controls
    @objc func volumeChanged(notification: NSNotification) {
        if let userInfo = notification.userInfo {
            
            if let newVolumeValue = userInfo["AVSystemController_AudioVolumeNotificationParameter"] as? Float {
                volumeValue = newVolumeValue
            }
            
            if let volumeChangeType = userInfo["AVSystemController_AudioVolumeChangeReasonNotificationParameter"] as? String {
                
                guard volumeChangeType == "ExplicitVolumeChange" else {return}
                guard animationActive == false else {return}

                volumeActions()
        }
    }
        
    }
    
    // mode control
    
    @objc func changeMode() {
        
        guard animationActive == false else {return}
        switch currentMode {
        case .play: do {
            
            // change to timer mode
            
            recMode()
            
            qtView.leftLabel.text = "TIMER"
            recController.setupCamera()
            currentMode = .timer
            print("TIMER")
            }
        // timer
        case .timer: do {
            
            // change to rec mode
            qtView.leftLabel.text = "REC"
            currentMode = .rec
            print("REC")
            }
            
        case .tutorial: do {
            volumeIncrease = true
            volumeActions()
        }
            
        // rec
        default: do {
            
            playMode()
        }
        }
    }
    
// play mode
    
    func tutorialBegin() {
        tutorialActive = true
        currentMode = .tutorial
        qtView.tutorialSlide(1)
//        qtView.changeModeButtonHighlight(true)
    }
    
    func tutorialEnd() {
        tutorialActive = false
        currentTutorialSlide = 1
        qtView.tutorialSlide(9)
        currentMode = .rec
    }
    
    func changePhoto(advance: Bool) {

        guard imagePaths.count > 0 else {return}
        if advance {

            if currentImage == imagePaths.count - 1 {
                currentImage = 0
            } else {
                currentImage += 1
            }

        } else {

            if currentImage == 0 {
                currentImage = imagePaths.count - 1
            } else {
                currentImage -= 1
            }
        }
        
        qtView.rightLabel.text = (currentImage + 1).description
    }
    
// animation stuff
    
    func recMode() {
        
        qtView.bottomLabelsIsHidden(true)
        
        // black view animation setup
        qtView.topConstraint.constant = 0
        self.view.layoutIfNeeded()
        qtView.blackView.isHidden = true
        
        qtView.rightLabel.text = imagePaths.count.description
        
    }
    
    func playMode() {
        recController.cleanup()
        // change to play mode
        if imagePaths.count != 0 {
            qtView.blackView.isHidden = false
            self.animationActive = true
            playAnimation()
        }

        qtView.leftLabel.text = "PLAY"
        if imagePaths.count == 0 {
            qtView.bottomLabelsIsHidden(true)
            qtView.rightLabel.text = "Null"
            qtView.previewView.image = UIImage()
        }
        else {
            qtView.bottomLabelsIsHidden(false)
            qtView.rightLabel.text = (currentImage + 1).description
            attemptImageToPreviewView()
        }
        
        currentMode = .play

    }
        
    @objc func playAnimation() {
        qtView.topConstraint.constant = 0
        self.view.layoutIfNeeded()
        qtView.topConstraint.constant = qtView.previewView.frame.height
        UIView.animate(withDuration: 4, animations: {
            self.view.layoutIfNeeded()
        }, completion: { _ in
            self.animationActive = false
        })
    }
        
}

// persistent

extension ContainerViewController {
    
    func savePhotoLocally(_ image: UIImage) {
        
        // for timer
        animationActive = true
        qtView.blackView.isHidden = false
        
        persistentStorage.saveData(image) { (filePath, success) in
            
            if success != false {
                
                imagePaths.append(filePath)

                recController.cleanup()
                
                if let img = flipImage(image) {
                    qtView.previewView.image = img
                }
                else {
                    print("ERROR FLIPPIN IN SAVE")
                    qtView.previewView.image = UIImage()
                }
                
                qtView.leftLabel.isHidden = true
                qtView.rightLabel.isHidden = true
                
                // setup black view at top
                qtView.topConstraint.constant = 0
                qtView.layoutIfNeeded()
                
                // animate black view down
                qtView.topConstraint.constant = qtView.previewView.frame.height
                UIView.animate(withDuration: 4, animations: {
                    self.qtView.layoutIfNeeded()
                }, completion: { _ in
                    
                    // after two seconds make make image dissappear / display regular rec view
                    Timer.scheduledTimer(withTimeInterval: 2, repeats: false, block: { (_) in
                        print("save image started 4")

                        self.qtView.blackView.isHidden = true
                        self.qtView.rightLabel.text = self.imagePaths.count.description
                        
                        self.qtView.leftLabel.isHidden = false
                        self.qtView.rightLabel.isHidden = false
                        self.animationActive = false
                        self.recController.setupCamera()
                        
                    })

                })

            } else {
                errorAlert()
                print("FAILURE TO SAVE")
            }
            
        }
    }
    
    func flipImage(_ image: UIImage) -> UIImage? {
        guard let cg = image.cgImage else {return nil}
        return UIImage(cgImage: cg, scale: 1.0, orientation: .right)
    }
    
    // delete from persistent
    @objc func deletePhoto() {
        let toDeletePath = imagePaths[currentImage]
        imagePaths.remove(at: currentImage)
        print("IMAGE PATHS", imagePaths)
        persistentStorage.deleteData(toDeletePath) { _ in
            changePhoto(advance: false)
            print("CURRENT IMAGE DELETED", currentImage, imagePaths.count)
            guard imagePaths.count != 0 else {return playMode()}
            attemptImageToPreviewView()
        }

    }
    
    func deleteAll() {
        for _ in imagePaths {
            deletePhoto()
        }
    }
    
}

extension ContainerViewController {
    
    // save to album
    @objc func savePhoto(_ photoPath: String) {
        guard let image = persistentStorage.getImage(imagePaths[currentImage]) else {return errorAlert()}
        guard let flip = flipImage(image) else {return errorAlert()}
        UIImageWriteToSavedPhotosAlbum(flip, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
        
    }
    
    func errorAlert() {
        let ac = UIAlertController(title: "Sorry About That", message: "Something weird happened :( Please try again.", preferredStyle: .alert)
        
            ac.addAction(UIAlertAction(title: "OK", style: .default) { _ in

        })
    }
    
    @objc func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        if let error = error {
            // we got back an error!
            let ac = UIAlertController(title: "Sorry About That", message: error.localizedDescription, preferredStyle: .alert)
            
            ac.addAction(UIAlertAction(title: "OK", style: .default) { _ in

            })

        } else {

            self.animationActive = true
            playAnimation()
            
        }
    }
    
    // save all to album
    
    func saveAll() {
        
        for path in imagePaths {
            guard let image = persistentStorage.getImage(path) else {return errorAlert()}
            guard let flip = flipImage(image) else {return errorAlert()}
            UIImageWriteToSavedPhotosAlbum(flip, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
        }
        
    }
    
}

// pop up button

extension ContainerViewController {
    
    @objc func presentPopUpView() {
        let ac = UIAlertController(title: "More info", message: nil, preferredStyle: .actionSheet)
        
        ac.addAction(UIAlertAction(title: "Find out more about Deaton", style: .default) { _ in
            if let url = URL(string:"https://deatonchrisanthony.com") {
                UIApplication.shared.open(url)
            }
            guard self.tutorialActive else {return }
            self.tutorialEnd()
        })
        
        ac.addAction(UIAlertAction(title: "Save All", style: .default) { [unowned self] _ in
            self.saveAll()
            guard self.tutorialActive else {return }
            self.tutorialEnd()
        })
        
        ac.addAction(UIAlertAction(title: "Delete All", style: .default) { [unowned self] _ in
            self.deleteAll()
            guard self.tutorialActive else {return }
            self.tutorialEnd()
        })
        
        ac.addAction(UIAlertAction(title: "Tutorial", style: .default) { [unowned self] _ in
            guard !self.tutorialActive else {return }
            self.tutorialBegin()
        })
        
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel){ [unowned self] _ in
            guard self.tutorialActive else {return }
            self.tutorialEnd()
        })
        present(ac, animated: true)
    }
    
}

enum Mode {
    case rec
    case play
    case timer
    case tutorial
}
