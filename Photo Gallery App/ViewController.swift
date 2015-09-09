//
//  ViewController.swift
//  Photo Gallery App
//
//  Created by luyao ma on 4/18/15.
//  Copyright (c) 2015 luyao ma. All rights reserved.
//

import UIKit
import Photos
import Parse

let reuseIdentifier = "PhotoCell"
let albumName = "My App"

class ViewController: UIViewController, UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout,UIImagePickerControllerDelegate,UINavigationControllerDelegate{
    
    var assetCollection: PHAssetCollection!
    var photoAsset: PHFetchResult!
    var albumFound: Bool = false
    
//Actions & Outlets

    @IBAction func ButtonCamera(sender: AnyObject) {
        if(UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera)){
            //load the camera interface
            var picker : UIImagePickerController = UIImagePickerController()
            picker.sourceType = UIImagePickerControllerSourceType.Camera
            picker.delegate = self
            picker.allowsEditing = false
            self.presentViewController(picker, animated: true, completion: nil)
        }else{
            //no camera available
            var alert = UIAlertController(title: "Error", message: "camera unavailable!", preferredStyle: .Alert)
            alert.addAction(UIAlertAction(title: "okay", style: .Default, handler: {(alertAction)in
            alert.dismissViewControllerAnimated(true, completion: nil)
            }))
            self.presentViewController(alert, animated: true, completion: nil)
        }
    }
    
    
    @IBAction func ButtonAlbum(sender: AnyObject) {
        var picker : UIImagePickerController = UIImagePickerController()
        picker.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
        picker.delegate = self
        picker.allowsEditing = false
        self.presentViewController(picker, animated: true, completion: nil)
    }
    
    @IBAction func ButtonLogout(sender: AnyObject) {
        NSUserDefaults.standardUserDefaults().setBool(false, forKey: "UserLoggedIn")
        NSUserDefaults.standardUserDefaults().synchronize()
        PFUser.logOutInBackgroundWithBlock({(error: NSError?) -> Void in
            self.navigationController?.popToRootViewControllerAnimated(true)
        })
    }
    
    
    
//    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var collectionView: UICollectionView! = nil
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.collectionView.backgroundColor = UIColor(patternImage: UIImage(named: "general.jpg")!)
    // check if the folder exists, if not, create it
        let fetchOptions = PHFetchOptions()
        fetchOptions.predicate = NSPredicate(format: "title = %@", albumName)
        
        let collection = PHAssetCollection.fetchAssetCollectionsWithType(.Album, subtype: .Any, options: fetchOptions)
        if (collection.firstObject != nil){
            //found the ablbum
            self.albumFound = true
            self.assetCollection = collection.firstObject as! PHAssetCollection
        }else{
            //create the folder
            NSLog("\nFolder \"%@\" does not exist\n creating now...", albumName)
            PHPhotoLibrary.sharedPhotoLibrary().performChanges({
            let request = PHAssetCollectionChangeRequest.creationRequestForAssetCollectionWithTitle(albumName)
                },
            completionHandler: {(success: Bool, error: NSError! )in
                NSLog("Creation of folder -> %@", (success ? "Success!":"Error!"))
                self.albumFound = (success ? true: false)
            })
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        //fetch the photo from collection
        self.navigationController?.hidesBarsOnTap = false
        self.photoAsset = PHAsset.fetchAssetsInAssetCollection(self.assetCollection, options: nil)
        //handle no photos in assetcollection
        //have a label says "No photos"
        self.collectionView.reloadData()
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier! as String == "viewLargePhoto"){
            let controller: ViewPhoto = segue.destinationViewController as! ViewPhoto
            let indexPath: NSIndexPath = self.collectionView.indexPathForCell(sender as! UICollectionViewCell)!
            controller.index = indexPath.item
            controller.photoAsset = self.photoAsset
            controller.assetcloccetion = self.assetCollection
        }
    }
    
//UICollectionViewDataSource methods
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int{
        var count: Int = 0
        if(self.photoAsset != nil){
            count = self.photoAsset.count
        }
        return count;
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell{
        let cell: PhotoThumbnail =  collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! PhotoThumbnail
        
        //modify cell
        let asset:PHAsset = self.photoAsset[indexPath.item] as! PHAsset
        //
        PHImageManager.defaultManager().requestImageForAsset(asset, targetSize: PHImageManagerMaximumSize, contentMode: .AspectFill, options: nil, resultHandler:
            {(result, info) in
                cell.setThumbnailImage(result)
            })
        return cell
    }
//UIcollection Layout: methods
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAtIndex section: Int) -> CGFloat{
        return 4
    }
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAtIndex section: Int) -> CGFloat{
        return 1
    }
 
//UIImagePickerControllerDelege methods
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [NSObject : AnyObject]){
        let image = info[UIImagePickerControllerOriginalImage] as? UIImage
//        let editedImage = info[UIImagePickerControllerEditedImage] as? UIImage
        PHPhotoLibrary.sharedPhotoLibrary().performChanges({
            let createAssetRequest = PHAssetChangeRequest.creationRequestForAssetFromImage(image)
            let assetPlaceholder = createAssetRequest.placeholderForCreatedAsset
            createAssetRequest
            let albumChangeRequest = PHAssetCollectionChangeRequest(forAssetCollection: self.assetCollection, assets: self.photoAsset)
            albumChangeRequest.addAssets([assetPlaceholder])
            }, completionHandler: {(success: Bool, error: NSError! )in
                NSLog("Adding image to library -> %@", (success ? "Success!":"Error!"))
                picker.dismissViewControllerAnimated(true, completion: nil)
        })
    }
    func imagePickerControllerDidCancel(picker: UIImagePickerController){
        picker.dismissViewControllerAnimated(true, completion: nil)
    }
    
    
}

