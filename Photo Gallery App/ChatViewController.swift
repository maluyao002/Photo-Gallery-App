//
//  ChatViewController.swift
//  Photo Gallery App
//
//  Created by luyao ma on 4/26/15.
//  Copyright (c) 2015 luyao ma. All rights reserved.
//

import UIKit
import MultipeerConnectivity
import Photos
import AssetsLibrary

class ChatViewController: UIViewController, UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource, UIImagePickerControllerDelegate,UINavigationControllerDelegate
{
    @IBOutlet weak var txtChat: UITextField!
    
    @IBOutlet weak var tblChat: UITableView!
    
    var messagesArray: [Dictionary<String, String>] = []
    
    var sendImage: UIImage!
    
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
    let context = CIContext(options: nil)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        tblChat.delegate = self
        tblChat.dataSource = self
        
        tblChat.estimatedRowHeight = 60.0
        tblChat.rowHeight = UITableViewAutomaticDimension
        
        txtChat.delegate = self
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "handleMPCReceivedDataWithNotification:", name: "receivedMPCDataNotification", object: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool) {
        self.navigationController?.hidesBarsOnTap = true
    }

    // IBAction method implementation
    
    @IBAction func endChat(sender: AnyObject) {
        let messageDictionary: [String: String] = ["message": "_end_chat_"]
        if appDelegate.mpcManager.sendData(dictionaryWithData: messageDictionary, toPeer: appDelegate.mpcManager.session.connectedPeers[0] as! MCPeerID){
            self.dismissViewControllerAnimated(true, completion: { () -> Void in
                self.appDelegate.mpcManager.session.disconnect()
            })
        }
    }
    
// ****************change start here *********
    
    
//    Exchange Photos
    @IBAction func exchangePhoto(sender: AnyObject) {
        var picker : UIImagePickerController = UIImagePickerController()
        picker.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
        picker.delegate = self
        picker.allowsEditing = false
        self.presentViewController(picker, animated: true, completion: nil)
    }
    
    //UIImagePickerControllerDelege methods
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [NSObject : AnyObject]){
        sendImage = info[UIImagePickerControllerOriginalImage] as? UIImage
       
        let imageData:NSData = UIImagePNGRepresentation(sendImage)
        let imageDictionary: [String: NSData] = ["Image": imageData]
        appDelegate.mpcManager.sendImage(dictionaryWithData: imageDictionary, toPeer: appDelegate.mpcManager.session.connectedPeers[0] as! MCPeerID)
        picker.dismissViewControllerAnimated(true, completion: nil)
    }
    func imagePickerControllerDidCancel(picker: UIImagePickerController){
        picker.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func handleReceuvedImage(notification: NSNotification){
        let receivedDataDictionary = notification.object as! Dictionary<String, AnyObject>
        let data = receivedDataDictionary["data"] as? NSData
        let dataDictionary = NSKeyedUnarchiver.unarchiveObjectWithData(data!) as! Dictionary<String, NSData>
        var receivedImage:UIImage?
        if let dictionary:NSData = dataDictionary["Image"]{
            receivedImage = UIImage(data: dictionary)
        }
        let ciImage = CIImage(image: receivedImage)
        let saveImage = context.createCGImage(ciImage, fromRect: ciImage.extent())
        ALAssetsLibrary().writeImageToSavedPhotosAlbum(saveImage, orientation: ALAssetOrientation.Up, completionBlock: { (path:NSURL!, error:NSError!) -> Void in
            if path != nil{
                var myAlert = UIAlertController(title: "Alert", message: "New Image has been saved!", preferredStyle: UIAlertControllerStyle.Alert)
                let okAction = UIAlertAction(title: "Alert", style: UIAlertActionStyle.Default, handler: {
                    action in self.dismissViewControllerAnimated(true, completion: nil)
                })
                myAlert.addAction(okAction)
                self.presentViewController(myAlert, animated: true, completion: nil)
            }else{
                println("\(path)")
            }
        })
//        PHPhotoLibrary.sharedPhotoLibrary().performChanges({
//            let createAssetRequest = PHAssetChangeRequest.creationRequestForAssetFromImage(receivedImage)
//            let assetPlaceholder = createAssetRequest.placeholderForCreatedAsset
//            createAssetRequest
//            let assetCollection = PHAssetCollection.fetchAssetCollectionsWithType(.Album, subtype: <#PHAssetCollectionSubtype#>, options: <#PHFetchOptions!#>)
//            let albumChangeRequest = PHAssetCollectionChangeRequest(forAssetCollection: self.assetCollection, assets: self.photoAsset)
//            albumChangeRequest.addAssets([assetPlaceholder])
//            }, completionHandler: {(success: Bool, error: NSError! )in
//                NSLog("Adding image to library -> %@", (success ? "Success!":"Error!"))
//                picker.dismissViewControllerAnimated(true, completion: nil)
//        })
    }
    
// ****************change start here *********

    // UITableView related method implementation
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messagesArray.count
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier("idCell") as! UITableViewCell
        
        let currentMessage = messagesArray[indexPath.row] as Dictionary<String, String>
        
        if let sender = currentMessage["sender"] {
            var senderLabelText: String
            var senderColor: UIColor
            
            if sender == "self"{
                senderLabelText = "I said:"
                senderColor = UIColor.purpleColor()
            }
            else{
                senderLabelText = sender + " said:"
                senderColor = UIColor.orangeColor()
            }
            
            cell.detailTextLabel?.text = senderLabelText
            cell.detailTextLabel?.textColor = senderColor
        }
        
        if let message = currentMessage["message"] {
            cell.textLabel?.text = message
        }
        
        return cell
    }
    
    
    
    // UITextFieldDelegate method implementation
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        let messageDictionary: [String: String] = ["message": textField.text]
        
        if appDelegate.mpcManager.sendData(dictionaryWithData: messageDictionary, toPeer: appDelegate.mpcManager.session.connectedPeers[0] as! MCPeerID){
            
            var dictionary: [String: String] = ["sender": "self", "message": textField.text]
            messagesArray.append(dictionary)
            
            self.updateTableview()
        }
        else{
            println("Could not send data")
        }
        
        textField.text = ""
        
        return true
    }
    
    
    // Custom method implementation
    
    func updateTableview(){
        tblChat.reloadData()
        
        if self.tblChat.contentSize.height > self.tblChat.frame.size.height {
            tblChat.scrollToRowAtIndexPath(NSIndexPath(forRow: messagesArray.count - 1, inSection: 0), atScrollPosition: UITableViewScrollPosition.Bottom, animated: true)
        }
    }
    
    
    func handleMPCReceivedDataWithNotification(notification: NSNotification) {
        // Get the dictionary containing the data and the source peer from the notification.
        let receivedDataDictionary = notification.object as! Dictionary<String, AnyObject>
        
        // "Extract" the data and the source peer from the received dictionary.
        let data = receivedDataDictionary["data"] as? NSData
        let fromPeer = receivedDataDictionary["fromPeer"] as! MCPeerID
        
        // Convert the data (NSData) into a Dictionary object.
        let dataDictionary = NSKeyedUnarchiver.unarchiveObjectWithData(data!) as! Dictionary<String, String>
        
        // Check if there's an entry with the "message" key.
        if let message = dataDictionary["message"] {
            // Make sure that the message is other than "_end_chat_".
            if message != "_end_chat_"{
                // Create a new dictionary and set the sender and the received message to it.
                var messageDictionary: [String: String] = ["sender": fromPeer.displayName, "message": message]
                
                // Add this dictionary to the messagesArray array.
                messagesArray.append(messageDictionary)
                
                // Reload the tableview data and scroll to the bottom using the main thread.
                NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
                    self.updateTableview()
                })
            }
            else{
                // In this case an "_end_chat_" message was received.
                // Show an alert view to the user.
                let alert = UIAlertController(title: "", message: "\(fromPeer.displayName) ended this chat.", preferredStyle: UIAlertControllerStyle.Alert)
                
                let doneAction: UIAlertAction = UIAlertAction(title: "Okay", style: UIAlertActionStyle.Default) { (alertAction) -> Void in
                    self.appDelegate.mpcManager.session.disconnect()
                    self.dismissViewControllerAnimated(true, completion: nil)
                }
                
                alert.addAction(doneAction)
                
                NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
                    self.presentViewController(alert, animated: true, completion: nil)
                })
            }
        }
    }
}

