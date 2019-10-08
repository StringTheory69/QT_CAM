//
//  ImagePreviewControllerViewController.swift
//  QT CAM
//
//  Created by jason smellz on 10/8/19.
//  Copyright © 2019 jacob. All rights reserved.
//

import UIKit

class ImagePreviewViewController: UIViewController {
    
    var previewView: UIImageView!
    var saveButton: UIButton!
    var closeButton: UIButton!
    var image: UIImage!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .black
        
        previewView = UIImageView()
        previewView.image = image
        previewView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(previewView)
        previewView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        previewView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        previewView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        previewView.heightAnchor.constraint(equalTo: view.widthAnchor, multiplier: 4/3).isActive = true
        
        // transparent view for formatting takePhotoButton
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
        
        saveButton = UIButton()
        saveButton.setTitle("Save", for: .normal)
        saveButton.setTitleColor(.white, for: .normal)
        saveButton.backgroundColor = UIColor.systemBlue
        saveButton.translatesAutoresizingMaskIntoConstraints = false
        saveButton.addTarget(self, action: #selector(savePhoto), for: .touchUpInside)
        view.addSubview(saveButton)
        saveButton.heightAnchor.constraint(equalToConstant: 40).isActive = true
        saveButton.widthAnchor.constraint(equalToConstant: 90).isActive = true
        saveButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        saveButton.centerYAnchor.constraint(equalTo: bottomFormatter.centerYAnchor).isActive = true
        
        closeButton = UIButton()
        closeButton.setTitle("Cancel", for: .normal)
//        closeButton.setImage(#imageLiteral(resourceName: "close"), for: .normal)
        closeButton.setTitleColor(.white, for: .normal)
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        closeButton.addTarget(self, action: #selector(close), for: .touchUpInside)
        view.addSubview(closeButton)
        closeButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10).isActive = true
        closeButton.centerYAnchor.constraint(equalTo: topFormatter.centerYAnchor).isActive = true
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        // save button round corner
        saveButton.layer.cornerRadius = 15
    }
    
    @objc func savePhoto() {
        
        UIImageWriteToSavedPhotosAlbum(image, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
        
    }
    
    @objc func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        if let error = error {
            // we got back an error!
            let ac = UIAlertController(title: "Save error", message: error.localizedDescription, preferredStyle: .alert)
            
            ac.addAction(UIAlertAction(title: "OK", style: .default) { _ in
                self.close()
                })
            present(ac, animated: true)
            
        } else {
//            let ac = UIAlertController(title: "Saved!", message: "Your altered image has been saved to your photos.", preferredStyle: .alert)
//            ac.addAction(UIAlertAction(title: "OK", style: .default ){ _ in
//                self.close()
//            })
//            present(ac, animated: true)
            self.close()

        }
    }
    
    @objc func close() {
        self.dismiss(animated: true, completion: nil)
    }

}
