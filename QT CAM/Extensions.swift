//
//  Extensions.swift
//  QT CAM
//
//  Created by jason smellz on 10/8/19.
//  Copyright © 2019 jacob. All rights reserved.
//

import UIKit

extension UIImage {
    //    func resizeWithPercent(percentage: CGFloat) -> UIImage? {
    //        let imageView = UIImageView(frame: CGRect(origin: .zero, size: CGSize(width: size.width * percentage, height: size.height * percentage)))
    //        imageView.contentMode = .scaleAspectFit
    //        imageView.image = self
    //        UIGraphicsBeginImageContextWithOptions(imageView.bounds.size, false, scale)
    //        guard let context = UIGraphicsGetCurrentContext() else { return nil }
    //        imageView.layer.render(in: context)
    //        guard let result = UIGraphicsGetImageFromCurrentImageContext() else { return nil }
    //        UIGraphicsEndImageContext()
    //        return result
    //    }
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

extension UIColor {
    static let systemBlue = UIColor(red: 0/255, green: 122/255, blue: 255/255, alpha: 1)
    // etc
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
