    //
//  PhotoThumbnail.swift
//  Photo Gallery App
//
//  Created by luyao ma on 4/19/15.
//  Copyright (c) 2015 luyao ma. All rights reserved.
//

import UIKit

class PhotoThumbnail: UICollectionViewCell {
    
    @IBOutlet var imageview: UIImageView! = nil
    
    func setThumbnailImage(_ thumbnailImage: UIImage){
        self.imageview.image = thumbnailImage
    }
    
}
