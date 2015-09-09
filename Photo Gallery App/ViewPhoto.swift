//
//  ViewPhoto.swift
//  Photo Gallery App
//
//  Created by luyao ma on 4/19/15.
//  Copyright (c) 2015 luyao ma. All rights reserved.
//

import UIKit
import Photos
import CoreImage
import AssetsLibrary

class ViewPhoto: UIViewController, UIScrollViewDelegate{

    let context = CIContext(options: nil)
    var assetcloccetion: PHAssetCollection!
    var photoAsset: PHFetchResult!
    var index: Int = 0
    var filter: CIFilter!
    var extent: CGRect!
    var scaleFactor: CGFloat!
    var originalPhoto: UIImage!
    var editPhoto:UIImageView = UIImageView()
    
    @IBAction func ButtonCancel(sender: AnyObject) {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    @IBAction func ButtonExport(sender: AnyObject) {
        let image = self.ImageView.image!
        let imageArray : [UIImage] = [image]
        let controller:UIActivityViewController = UIActivityViewController(activityItems: imageArray, applicationActivities: nil)
        //can not add more sharing methods
        controller.excludedActivityTypes = [UIActivityTypePostToTwitter,UIActivityTypePostToFacebook,UIActivityTypePostToWeibo, UIActivityTypeMessage]
        self.presentViewController(controller, animated: true, completion: nil)
    }
    
    
    @IBAction func ButtonTrash(sender: AnyObject) {
        let alert = UIAlertController(title: "Delete Photo", message: "Are you sure to delete this photo?", preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: "Yes", style: .Default, handler: {(alertAction) in
            //Delete Photo
            PHPhotoLibrary.sharedPhotoLibrary().performChanges({
                let request = PHAssetCollectionChangeRequest(forAssetCollection: self.assetcloccetion)
                request.removeAssets([self.photoAsset[self.index]])
                }, completionHandler: {(success,error) in
                    NSLog("\nDeleted Image ->%@", (success ? "Success":"Error!"))
                    alert.dismissViewControllerAnimated(true, completion: nil)
                    self.photoAsset = PHAsset.fetchAssetsInAssetCollection(self.assetcloccetion, options: nil)
                    if (self.photoAsset.count == 0){
                        //no photo left
                        self.ImageView.image = nil
                        println("No photo left!")
                    }
                    if (self.index >= self.photoAsset.count){
                        self.index = self.photoAsset.count - 1
                    }
                    self.displayPhoto()
                })
        }))
        alert.addAction(UIAlertAction(title: "No", style: .Cancel, handler: {(alertAction) in
            //Dont delete photo
            alert.dismissViewControllerAnimated(true, completion: nil)
        }))
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    @IBAction func ButtonEdit(sender: AnyObject) {
        ImageView.hidden = true
        ScrollView.hidden = false
        let image = self.ImageView.image!
        editPhoto.image = image
        editPhoto.contentMode = UIViewContentMode.Center
        editPhoto.frame = CGRectMake(0, 0, image.size.width, image.size.height)
        ScrollView.contentSize = image.size
        
        let scrollViewFrame = ScrollView.frame
        let scaleWidth = scrollViewFrame.size.width / ScrollView.contentSize.width
        let scaleHeight = scrollViewFrame.size.height / ScrollView.contentSize.height
        let minScale = min(scaleHeight,scaleWidth)
        ScrollView.minimumZoomScale = minScale
        ScrollView.maximumZoomScale = 1
        ScrollView.zoomScale = minScale
        centerScollViewContents()
    }
    
    
    //
    @IBOutlet weak var ImageView: UIImageView!
    
    @IBOutlet weak var ScrollView: UIScrollView!
    
    @IBOutlet weak var photoEffectInstantt: UIButton!
    
    @IBOutlet weak var photoEffectNoir: UIButton!
    
    @IBOutlet weak var photoEffectTransfer: UIButton!
    
    @IBOutlet weak var photoEffectFade: UIButton!
    
    @IBOutlet weak var photoEffectProcess: UIButton!
    
    //show the filters
    @IBAction func ButtonFilter(sender: AnyObject) {
        photoEffectInstantt.hidden = false
        photoEffectNoir.hidden = false
        photoEffectTransfer.hidden = false
        photoEffectFade.hidden = false
        photoEffectProcess.hidden = false
    }
    
    // button oldtime
    @IBAction func photoEffectInstantt(sender: AnyObject) {
        filter = CIFilter(name: "CIPhotoEffectInstant")
        self.outputImage()
    }
    
    // button black
    @IBAction func photoEffectNoir(sender: AnyObject) {
        filter = CIFilter(name: "CIPhotoEffectNoir")
        outputImage()
    }
    
    //button classic
    @IBAction func photoEffectTransfer(sender: AnyObject) {
        filter = CIFilter(name: "CIPhotoEffectTransfer")
        outputImage()
    }

    @IBAction func photoEffectFade(sender: AnyObject) {
        filter = CIFilter(name: "CIPhotoEffectFade")
        outputImage()
    }
    
    @IBAction func photoEffectProcess(sender: AnyObject) {
        filter = CIFilter(name: "CIPhotoEffectProcess")
        outputImage()
    }
    
    @IBAction func ButtonSave(sender: AnyObject) {
        if ScrollView.hidden == true {
        let ciImage = CIImage(image: ImageView.image)
        let saveImage = context.createCGImage(ciImage, fromRect: ciImage.extent())
        ALAssetsLibrary().writeImageToSavedPhotosAlbum(saveImage, orientation: ALAssetOrientation.Up, completionBlock: { (path:NSURL!, error:NSError!) -> Void in
            if path != nil{
                var myAlert = UIAlertController(title: "Alert", message: "New Image has been saved!", preferredStyle: UIAlertControllerStyle.Alert)
                let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: {
                    action in self.dismissViewControllerAnimated(true, completion: nil)
                })
                myAlert.addAction(okAction)
                self.presentViewController(myAlert, animated: true, completion: nil)
            }else{
                println("\(path)")
            }
        })
        }else{
            UIGraphicsBeginImageContextWithOptions(ScrollView.bounds.size, true, UIScreen.mainScreen().scale)
            let offset = ScrollView.contentOffset
            CGContextTranslateCTM(UIGraphicsGetCurrentContext(), -offset.x, -offset.y)
            ScrollView.layer.renderInContext(UIGraphicsGetCurrentContext())
            let image = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            UIImageWriteToSavedPhotosAlbum(image,nil, nil, nil)
            var myAlert = UIAlertController(title: "Alert", message: "New Image has been saved!", preferredStyle: UIAlertControllerStyle.Alert)
            let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: {
                action in self.dismissViewControllerAnimated(true, completion: nil)
            })
            myAlert.addAction(okAction)
            self.presentViewController(myAlert, animated: true, completion: nil)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        photoEffectInstantt.hidden = true
        photoEffectNoir.hidden = true
        photoEffectTransfer.hidden = true
        photoEffectFade.hidden = true
        photoEffectProcess.hidden = true
        ScrollView.hidden = true
        ScrollView.delegate = self
        
        editPhoto.frame = CGRectMake(0, 0, ScrollView.frame.size.width, ScrollView.frame.size.height)
        editPhoto.userInteractionEnabled = true
        ScrollView.addSubview(editPhoto)
        
    }
    
    //set function to make image in the scrollview in the center
    func centerScollViewContents(){
        let boundsSize = ScrollView.bounds.size
        var contentsFrame = editPhoto.frame
        
        if contentsFrame.size.width < boundsSize.width{
            contentsFrame.origin.x = (boundsSize.width - contentsFrame.size.width) / 2
        }else{
            contentsFrame.origin.x = 0
        }
        
        if contentsFrame.size.height < boundsSize.height{
            contentsFrame.origin.y = (boundsSize.height - contentsFrame.size.height) / 2
        }else{
            contentsFrame.origin.y = 0
        }
        
        editPhoto.frame = contentsFrame
    }
    
    func scrollViewDidZoom(scrollView: UIScrollView) {
        centerScollViewContents()
    }
    
    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        return editPhoto
    }
    
    
    override func viewWillAppear(animated: Bool) {
        self.navigationController?.hidesBarsOnTap = true
        self.displayPhoto()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //Display the large Image
    func displayPhoto(){
        let imageManager = PHImageManager.defaultManager()
        var ID = imageManager.requestImageForAsset(self.photoAsset[self.index] as! PHAsset, targetSize: PHImageManagerMaximumSize, contentMode: .AspectFit, options: nil, resultHandler: {
            (result, info)->Void in
            self.ImageView.image = result
        })
        originalPhoto = self.ImageView.image
    }

    //display the image after filtering
    func outputImage(){
//        let currentEditing = originalPhoto
//        let inputImage = currentEditing
        if (ScrollView.hidden == true){
            let ciImage = CIImage(image: ImageView.image)
            filter.setDefaults()
            filter.setValue(ciImage, forKey: kCIInputImageKey)
            ImageView.image = UIImage(CGImage: context.createCGImage(filter.outputImage, fromRect: filter.outputImage.extent()))
        }else{
            let ciImage = CIImage(image: editPhoto.image)
            filter.setDefaults()
            filter.setValue(ciImage, forKey: kCIInputImageKey)
            editPhoto.image = UIImage(CGImage: context.createCGImage(filter.outputImage, fromRect: filter.outputImage.extent()))
        }
    }
    
}
