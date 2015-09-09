//
//  RecoverPwdViewController.swift
//  Photo Gallery App
//
//  Created by luyao ma on 4/23/15.
//  Copyright (c) 2015 luyao ma. All rights reserved.
//

import UIKit
import Parse

class RecoverPwdViewController: UIViewController {

    @IBOutlet weak var RecoverEmailTextField: UITextField!
    
    @IBAction func RecoverButton(sender: AnyObject) {
        
        let userEmail = RecoverEmailTextField.text
        
        PFUser.requestPasswordResetForEmailInBackground(userEmail, block:{(success:Bool, error:NSError?) -> Void in
            if(success){
                let successMessage  = "Email message is sent to you ar \(userEmail)"
                self.displayAlertMessage(successMessage)
                return
            }
            if(error !== nil){
                let errorMessage:String = error!.userInfo!["error"] as! String
                self.displayAlertMessage(errorMessage)
            }
            
        })
        
    }
    
    func displayAlertMessage(message: String){
        //display alert message
        var myAlert = UIAlertController(title: "Alert", message: message, preferredStyle: UIAlertControllerStyle.Alert)
        
        let okAction = UIAlertAction(title: "ok", style: UIAlertActionStyle.Default, handler: nil)
        
        myAlert.addAction(okAction)
        
        self.presentViewController(myAlert, animated: true, completion: nil)
        
    }
    
    @IBAction func CancelButton(sender: AnyObject) {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor(patternImage: UIImage(named: "login.jpg")!)
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
