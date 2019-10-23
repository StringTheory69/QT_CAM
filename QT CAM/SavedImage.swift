//
//  SavedImage.swift
//  QT CAM
//
//  Created by jason smellz on 10/22/19.
//  Copyright © 2019 jacob. All rights reserved.
//

import UIKit

struct SavedImage {
    
    var image: UIImage!
    var filePath: String!
    
    init(image: UIImage, filePath: String) {
        self.image = image
        self.filePath = filePath
    }
}
