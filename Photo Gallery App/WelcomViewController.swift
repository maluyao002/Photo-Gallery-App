//
//  WelcomViewController.swift
//  Photo Gallery App
//
//  Created by luyao ma on 4/22/15.
//  Copyright (c) 2015 luyao ma. All rights reserved.
//

import UIKit

class WelcomViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor(patternImage: UIImage(named: "welcome.jpg")!)
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        let isUserLoggedIn = UserDefaults.standard.bool(forKey: "UserLoggedIn")
        if(isUserLoggedIn){
            self.performSegue(withIdentifier: "directsegue", sender: self)
        }
    }
    

}

