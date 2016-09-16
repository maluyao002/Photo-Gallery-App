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
    var photoAsset: PHFetchResult<AnyObject>!
    var index: Int = 0
    var filter: CIFilter!
    var extent: CGRect!
    var scaleFactor: CGFloat!
    var originalPhoto: UIImage!
    var editPhoto:UIImageView = UIImageView()
    
    @IBAction func ButtonCancel(_ sender: AnyObject) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func ButtonExport(_ sender: AnyObject) {
        let image = self.ImageView.image!
        let imageArray : [UIImage] = [image]
        let controller:UIActivityViewController = UIActivityViewController(activityItems: imageArray, applicationActivities: nil)
        //can not add more sharing methods
        controller.excludedActivityTypes = [UIActivityType.postToTwitter,UIActivityType.postToFacebook,UIActivityType.postToWeibo, UIActivityType.message]
        self.present(controller, animated: true, completion: nil)
    }
    
    
    @IBAction func ButtonTrash(_ sender: AnyObject) {
        let alert = UIAlertController(title: "Delete Photo", message: "Are you sure to delete this photo?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: {(alertAction) in
            //Delete Photo
            PHPhotoLibrary.shared().performChanges({
                let request = PHAssetCollectionChangeRequest(for: self.assetcloccetion)
                request!.removeAssets([self.photoAsset[self.index]])
                }, completionHandler: {(success,error) in
                    NSLog("\nDeleted Image ->%@", (success ? "Success":"Error!"))
                    alert.dismiss(animated: true, completion: nil)
                    self.photoAsset = PHAsset.fetchAssets(in: self.assetcloccetion, options: nil)
                    if (self.photoAsset.count == 0){
                        //no photo left
                        self.ImageView.image = nil
                        print("No photo left!")
                    }
                    if (self.index >= self.photoAsset.count){
                        self.index = self.photoAsset.count - 1
                    }
                    self.displayPhoto()
                })
        }))
        alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: {(alertAction) in
            //Dont delete photo
            alert.dismiss(animated: true, completion: nil)
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func ButtonEdit(_ sender: AnyObject) {
        ImageView.isHidden = true
        ScrollView.isHidden = false
        let image = self.ImageView.image!
        editPhoto.image = image
        editPhoto.contentMode = UIViewContentMode.center
        editPhoto.frame = CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height)
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
    @IBAction func ButtonFilter(_ sender: AnyObject) {
        photoEffectInstantt.isHidden = false
        photoEffectNoir.isHidden = false
        photoEffectTransfer.isHidden = false
        photoEffectFade.isHidden = false
        photoEffectProcess.isHidden = false
    }
    
    // button oldtime
    @IBAction func photoEffectInstantt(_ sender: AnyObject) {
        filter = CIFilter(name: "CIPhotoEffectInstant")
        self.outputImage()
    }
    
    // button black
    @IBAction func photoEffectNoir(_ sender: AnyObject) {
        filter = CIFilter(name: "CIPhotoEffectNoir")
        outputImage()
    }
    
    //button classic
    @IBAction func photoEffectTransfer(_ sender: AnyObject) {
        filter = CIFilter(name: "CIPhotoEffectTransfer")
        outputImage()
    }

    @IBAction func photoEffectFade(_ sender: AnyObject) {
        filter = CIFilter(name: "CIPhotoEffectFade")
        outputImage()
    }
    
    @IBAction func photoEffectProcess(_ sender: AnyObject) {
        filter = CIFilter(name: "CIPhotoEffectProcess")
        outputImage()
    }
    
    @IBAction func ButtonSave(_ sender: AnyObject) {
        if ScrollView.isHidden == true {
        let ciImage = CIImage(image: ImageView.image!!)
        let saveImage = context.createCGImage(ciImage!, from: (ciImage?.extent)!)
        ALAssetsLibrary().writeImageToSavedPhotosAlbum(saveImage, orientation: ALAssetOrientation.Up, completionBlock: { (path:URL!, error:NSError!) -> Void in
            if path != nil{
                var myAlert = UIAlertController(title: "Alert", message: "New Image has been saved!", preferredStyle: UIAlertControllerStyle.Alert)
                let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: {
                    action in self.dismissViewControllerAnimated(true, completion: nil)
                })
                myAlert.addAction(okAction)
                self.presentViewController(myAlert, animated: true, completion: nil)
            }else{
                print("\(path)")
            }
        })
        }else{
            UIGraphicsBeginImageContextWithOptions(ScrollView.bounds.size, true, UIScreen.main.scale)
            let offset = ScrollView.contentOffset
            UIGraphicsGetCurrentContext()?.translateBy(x: -offset.x, y: -offset.y)
            ScrollView.layer.render(in: UIGraphicsGetCurrentContext()!)
!        UIGraphicsEndImageContext()
            UIImageWriteToSavedPhotosAlbum(image!,nil, nil, nil)
            var myAlert = UIAlertController(title: "Alert", message: "New Image has been saved!", preferredStyle: UIAlertControllerStyle.alert)
            let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: {
                action in self.dismiss(animated: true, completion: nil)
            })
            myAlert.addAction(okAction)
            self.present(myAlert, animated: true, completion: nil)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        photoEffectInstantt.isHidden = true
        photoEffectNoir.isHidden = true
        photoEffectTransfer.isHidden = true
        photoEffectFade.isHidden = true
        photoEffectProcess.isHidden = true
        ScrollView.isHidden = true
        ScrollView.delegate = self
        
        editPhoto.frame = CGRect(x: 0, y: 0, width: ScrollView.frame.size.width, height: ScrollView.frame.size.height)
        editPhoto.isUserInteractionEnabled = true
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
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        centerScollViewContents()
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return editPhoto
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.hidesBarsOnTap = true
        self.displayPhoto()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //Display the large Image
    func displayPhoto(){
        let imageManager = PHImageManager.default()
        var ID = imageManager.requestImage(for: self.photoAsset[self.index] as! PHAsset, targetSize: PHImageManagerMaximumSize, contentMode: .aspectFit, options: nil, resultHandler: {
            (result, info)->Void in
            self.ImageView.image = result
        })
        originalPhoto = self.ImageView.image
    }

    //display the image after filtering
    func outputImage(){
//        let currentEditing = originalPhoto
//        let inputImage = currentEditing
        if (ScrollView.isHidden == true){
            let ciImage = CIImage(image: ImageView.image!)
            filter.setDefaults()
            filter.setValue(ciImage, forKey: kCIInputImageKey)
            ImageView.image = UIImage(cgImage: context.createCGImage(filter.outputImage!, from: (filter.outputImage?.!extent)!)!)
        }else{
            let ciImage = CIImage(image: editPhoto.image!!)
            filter.setDefaults()
            filter.setValue(ciImage, forKey: kCIInputImageKey)
            editPhoto.image = UIImage(cgImage: context.createCGImage(filter.outputImage!, from: (filter.outputImage?.!extent)!)!)
        }
    }
    
}
