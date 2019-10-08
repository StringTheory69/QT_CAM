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
    var image: UIImage!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .black
        
        previewView = UIImageView()
        previewView.image = image
        
        // blend here
        
        previewView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(previewView)
        previewView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        previewView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        previewView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        previewView.heightAnchor.constraint(equalTo: view.widthAnchor, multiplier: 4/3).isActive = true
        
    }
    
    @IBAction func closeButton(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    @IBAction func saveButton(_ sender: Any) {
        
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
            let ac = UIAlertController(title: "Saved!", message: "Your altered image has been saved to your photos.", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default ){ _ in
                self.close()
            })
            present(ac, animated: true)
        }
    }
    
    @objc func close() {
        self.dismiss(animated: true, completion: nil)
    }

}
