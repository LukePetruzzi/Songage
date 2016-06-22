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
    
    
    let kClientID = "2bb2c1d0c40c47e4940855b6b1f56112"
    let kCallbackURL = "songage://returnAfterLogin"
    let kTokenSwapURL = "http://localhost:1234/swap"
    let kTokenRefreshServiceURL = "http://localhost:1234/refresh"
    
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
        
        // set all parameters for the login url
        auth.clientID = kClientID
        auth.redirectURL = NSURL(string: kCallbackURL)
        auth.tokenSwapURL = NSURL(string: kTokenSwapURL)
        auth.tokenRefreshURL = NSURL(string: kTokenRefreshServiceURL)
        
        // get the login URL
        let loginURL = auth.loginURL
        
        UIApplication.sharedApplication().openURL(loginURL)
        
        
    }
    
    
    
}
