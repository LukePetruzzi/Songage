//
//  SpotifyLoginViewController.swift
//  Songage
//
//  Created by Luke Petruzzi on 6/22/16.
//  Copyright © 2016 Luke Petruzzi. All rights reserved.
//

import UIKit

class SpotifyLoginViewController: UIViewController {

    @IBOutlet weak var loginButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func loginButtonTapped(sender: UIButton)
    {
        // create an auth instance
        let auth = SPTAuth.defaultInstance()
        
        // get the login URL
        let loginURL = auth.loginURL
        
        UIApplication.sharedApplication().openURL(loginURL)
        
        
    }
    
    
    
}
