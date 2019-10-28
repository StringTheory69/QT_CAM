////
////  ImagePreviewControllerViewController.swift
////  QT CAM
////
////  Created by jason smellz on 10/8/19.
////  Copyright © 2019 jacob. All rights reserved.
////
//
//import UIKit
//import MediaPlayer
//
//class PlayController: NSObject {
//    
//    var currentImage: Int!
//    var imagesArray: [UIImage] = []
//    var container: ContainerViewController!
//
//    func setup(_ saved: [SavedImage]) -> UIImage {
//        imagesArray = []
//        currentImage = 0
//        for s in saved {
//            self.imagesArray.append(s.image)
//        }
//
//        guard imagesArray.count > 0 else {return UIImage() }
//
//        let flippedImage = UIImage(cgImage: self.imagesArray[currentImage].cgImage!, scale: 1.0, orientation: .right)
//        return flippedImage
//    }
//    
//    func changePhoto(_ advance: Bool) -> UIImage {
//        
//        guard imagesArray.count > 0 else {return UIImage() }
//        if advance {
//
//            if currentImage == imagesArray.count - 1 {
//                currentImage = 0
//            } else {
//                currentImage += 1
//            }
//            
//        } else {
//
//            if currentImage == 0 {
//                currentImage = imagesArray.count - 1
//            } else {
//                currentImage -= 1
//            }
//            
//        }
//
//        container.qtView.rightLabel.text = (currentImage + 1).description
//        let flippedImage = UIImage(cgImage: imagesArray[currentImage].cgImage!, scale: 1.0, orientation: .right)
//        return flippedImage
//    }
//}
//
////extension PlayController {
//    
////    @objc func savePhoto() {
////
////        UIImageWriteToSavedPhotosAlbum(imagesArray[currentImage], self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
////
////    }
//    
////    @objc func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
////        if let error = error {
////            // we got back an error!
////            let ac = UIAlertController(title: "Save error", message: error.localizedDescription, preferredStyle: .alert)
////
////            ac.addAction(UIAlertAction(title: "OK", style: .default) { _ in
//////                self.close()
////                })
//////            present(ac, animated: true)
////
////        } else {
////
////        }
////    }
//
//
////}
