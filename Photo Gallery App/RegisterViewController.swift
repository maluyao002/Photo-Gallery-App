//
//  RegisterViewController.swift
//  Photo Gallery App
//
//  Created by luyao ma on 4/22/15.
//  Copyright (c) 2015 luyao ma. All rights reserved.
//

import UIKit
import Parse

class RegisterViewController: UIViewController {

    @IBOutlet weak var UserEmailTextField: UITextField!
    
    @IBOutlet weak var UserPasswordTextField: UITextField!
    
    @IBOutlet weak var UserRePasswordTextFiled: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor(patternImage: UIImage(named: "login.jpg")!)
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func RegisterButton(_ sender: AnyObject) {
        
        let userEmail = UserEmailTextField.text
        let userPassword = UserPasswordTextField.text
        let userRePassword = UserRePasswordTextFiled.text
        
        //check empty field
        if ((userEmai!,l?.isEmpty)! || (userPassword?.isEmpty)! || (userRePassword?.isEmpty)!){
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
        
        let myUser:PFUser = PFUser()
        myUser.username = userEmail
        myUser.password = userPassword
        myUser.email = userEmail
        
        myUser.signUpInBackground
        {
            (success:Bool, error:NSError?) -> Void in
                //display alert message with confirmation
        var myAlert = UIAlertController(title: "Alert", message: "Registration is successful!", preferredStyle: UIAlertControllerStyle.alert)
        let okAction = UIAlertAction(title: "Alert", style: UIAlertActionStyle.default, handler: {
            action in self.dismiss(animated: true, completion: nil)
        })
        myAlert.addAction(okAction)
        self.present(myAlert, animated: true, completion: nil)
        }

    }
    
    func displayAlertMessage(_ message: String){
        let myAlert = UIAlertController(title: "Alert", message: message, preferredStyle: UIAlertControllerStyle.alert)
        
        let okAction = UIAlertAction(title: "Alert", style: UIAlertActionStyle.default, handler: nil)
        
        myAlert.addAction(okAction)
        
        self.present(myAlert, animated: true, completion: nil)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = true
    }
    
}
