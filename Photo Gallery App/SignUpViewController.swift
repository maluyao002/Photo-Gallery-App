//
//  SignUpViewController.swift
//  Photo Gallery App
//
//  Created by luyao ma on 4/22/15.
//  Copyright (c) 2015 luyao ma. All rights reserved.
//

import UIKit

class SignUpViewController: UIViewController {

    @IBOutlet weak var UserEmailTextField: UITextField!
    
    @IBOutlet weak var UserPasswordTextfield: UITextField!
    
    @IBOutlet weak var UserRePasswordTextfield: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func RegisterButton(sender: AnyObject) {
        
        let userEmail = UserEmailTextField.text
        let userPassword = UserPasswordTextfield.text
        let userRePassword = UserRePasswordTextfield.text
        
        //check empty field
        if (userEmail.isEmpty || userPassword.isEmpty || userRePassword.isEmpty){
            //display alert
            displayAlertMessage("All fields are required")
            return
        }
        
        if(userPassword != userRePassword){
            //display alert
            displayAlertMessage("Passwords do not match")
            return
        }
        
        //store data
        NSUserDefaults.standardUserDefaults().setObject(userEmail, forKey: "userEmail")
        NSUserDefaults.standardUserDefaults().setObject(userPassword, forKey: "userPassword")
        NSUserDefaults.standardUserDefaults().synchronize()
        
        //display alert message with confirmation
        var myAlert = UIAlertController(title: "Alert", message: "Registration is successful!", preferredStyle: UIAlertControllerStyle.Alert)
        let okAction = UIAlertAction(title: "Alert", style: UIAlertActionStyle.Default, handler: {
        action in self.dismissViewControllerAnimated(true, completion: nil)
        })
        
    }

    
    func displayAlertMessage(message: String){
        var myAlert = UIAlertController(title: "Alert", message: message, preferredStyle: UIAlertControllerStyle.Alert)
        
        let okAction = UIAlertAction(title: "Alert", style: UIAlertActionStyle.Default, handler: nil)
        
        myAlert.addAction(okAction)
        
        self.presentViewController(myAlert, animated: true, completion: nil)
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
