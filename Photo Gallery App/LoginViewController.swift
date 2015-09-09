//
//  LoginViewController.swift
//  Photo Gallery App
//
//  Created by luyao ma on 4/22/15.
//  Copyright (c) 2015 luyao ma. All rights reserved.
//

import UIKit
import Parse

class LoginViewController: UIViewController {

    @IBOutlet weak var EmailTextField: UITextField!
    
    @IBOutlet weak var PasswordTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor(patternImage: UIImage(named: "login.jpg")!)
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func LoginButton(sender: AnyObject) {
        
        let userEmail = EmailTextField.text
        let userPassword = PasswordTextField.text

        PFUser.logInWithUsernameInBackground(userEmail, password: userPassword, block: {(user:PFUser?, error:NSError?) -> Void in
            if user != nil{
            //login is successful
                NSUserDefaults.standardUserDefaults().setBool(true, forKey: "UserLoggedIn")
                NSUserDefaults.standardUserDefaults().synchronize()
                self.performSegueWithIdentifier("LoginToAlbumSegue", sender: self)
            }else {
                var myAlert = UIAlertController(title: "Alert", message: "User Email don't exist or wrong password!", preferredStyle: UIAlertControllerStyle.Alert)
                let okAction = UIAlertAction(title: "Alert", style: UIAlertActionStyle.Default, handler: {
                    action in self.dismissViewControllerAnimated(true, completion: nil)
                })
                myAlert.addAction(okAction)
                self.presentViewController(myAlert, animated: true, completion: nil)
            }
        })
        
        
    }
    
    override func viewWillAppear(animated: Bool) {
        self.navigationController?.navigationBarHidden = true
    }
}
