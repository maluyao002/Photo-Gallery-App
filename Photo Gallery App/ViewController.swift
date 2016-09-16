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
    var photoAsset: PHFetchResult<AnyObject>!
    var albumFound: Bool = false
    
//Actions & Outlets

    @IBAction func ButtonCamera(_ sender: AnyObject) {
        if(UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera)){
            //load the camera interface
            let picker : UIImagePickerController = UIImagePickerController()
            picker.sourceType = UIImagePickerControllerSourceType.camera
            picker.delegate = self
            picker.allowsEditing = false
            self.present(picker, animated: true, completion: nil)
        }else{
            //no camera available
            let alert = UIAlertController(title: "Error", message: "camera unavailable!", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "okay", style: .default, handler: {(alertAction)in
            alert.dismiss(animated: true, completion: nil)
            }))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    
    @IBAction func ButtonAlbum(_ sender: AnyObject) {
        let picker : UIImagePickerController = UIImagePickerController()
        picker.sourceType = UIImagePickerControllerSourceType.photoLibrary
        picker.delegate = self
        picker.allowsEditing = false
        self.present(picker, animated: true, completion: nil)
    }
    
    @IBAction func ButtonLogout(_ sender: AnyObject) {
        UserDefaults.standard.set(false, forKey: "UserLoggedIn")
        UserDefaults.standard.synchronize()
        PFUser.logOutInBackground(block: {(error: NSError?) -> Void in
            self.navigationController?.popToRootViewController(animated: true)
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
        
        let collection = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .any, options: fetchOptions)
        if (collection.firstObject != nil){
            //found the ablbum
            self.albumFound = true
            self.assetCollection = collection.firstObject as! PHAssetCollection
        }else{
            //create the folder
            NSLog("\nFolder \"%@\" does not exist\n creating now...", albumName)
            PHPhotoLibrary.shared().performChanges({
            let request = PHAssetCollectionChangeRequest.creationRequestForAssetCollection(withTitle: albumName)
                },
            completionHandler: {(success: Bool, error: NSError? )in
                NSLog("Creation of folder -> %@", (success ? "Success!":"Error!"))
                self.albumFound = (success ? true: false)
            })
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        //fetch the photo from collection
        self.navigationController?.hidesBarsOnTap = false
        self.photoAsset = PHAsset.fetchAssets(in: self.assetCollection, options: nil)
        //handle no photos in assetcollection
        //have a label says "No photos"
        self.collectionView.reloadData()
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier! as String == "viewLargePhoto"){
            let controller: ViewPhoto = segue.destination as! ViewPhoto
            let indexPath: IndexPath = self.collectionView.indexPath(for: sender as! UICollectionViewCell)!
            controller.index = (indexPath as NSIndexPath).item
            controller.photoAsset = self.photoAsset
            controller.assetcloccetion = self.assetCollection
        }
    }
    
//UICollectionViewDataSource methods
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int{
        var count: Int = 0
        if(self.photoAsset != nil){
            count = self.photoAsset.count
        }
        return count;
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell{
        let cell: PhotoThumbnail =  collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! PhotoThumbnail
        
        //modify cell
        let asset:PHAsset = self.photoAsset[(indexPath as NSIndexPath).item] as! PHAsset
        //
        PHImageManager.defaultManager().requestImageForAsset(asset, targetSize: PHImageManagerMaximumSize, contentMode: .AspectFill, options: nil, resultHandler:
            {(result, info) in
                cell.setThumbnailImage(result!)
            })
        return cell
    }
//UIcollection Layout: methods
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat{
        return 4
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat{
        return 1
    }
 
//UIImagePickerControllerDelege methods
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]){
        let image = info[UIImagePickerControllerOriginalImage] as? UIImage
//        let editedImage = info[UIImagePickerControllerEditedImage] as? UIImage
        PHPhotoLibrary.shared().performChanges({
            let createAssetRequest = PHAssetChangeRequest.creationRequestForAssetFromImage(image!)
            let assetPlaceholder = createAssetRequest.placeholderForCreatedAsset
            createAssetRequest
            let albumChangeRequest = PHAssetCollectionChangeRequest(for: self.assetCollection, assets: self.photoAsset)
            albumChangeRequest.addAssets([assetPlaceholder])
            }, completionHandler: {(success: Bool, error: NSError? )in
                NSLog("Adding image to library -> %@", (success ? "Success!":"Error!"))
                picker.dismiss(animated: true, completion: nil)
        })
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController){
        picker.dismiss(animated: true, completion: nil)
    }
    
    
}

