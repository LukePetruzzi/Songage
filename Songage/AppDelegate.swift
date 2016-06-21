//
//  AppDelegate.swift
//  Songage
//
//  Created by Luke Petruzzi on 6/20/16.
//  Copyright © 2016 Luke Petruzzi. All rights reserved.
//

import UIKit
import FBSDKCoreKit


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool
    {
        // Create the window
        self.window = UIWindow(frame: UIScreen.mainScreen().bounds)
        self.window?.makeKeyAndVisible()
        self.window?.rootViewController = ChooseImageViewController(nibName: "ChooseImageViewController", bundle: nil)
        
        // allow facebook to track installs and app opens
        FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
        
        
        // spotify test stuff
        // set the clientID
        SPTAuth.defaultInstance().clientID = "2bb2c1d0c40c47e4940855b6b1f56112"
        // set the redirect URL for after I make a call
        SPTAuth.defaultInstance().redirectURL = NSURL(string: "songage://returnAfterLogin")
        // set the scopes... there's only one needed
        SPTAuth.defaultInstance().requestedScopes = [SPTAuthStreamingScope]
        
        // construct a URL and open it
        let loginURL:NSURL = SPTAuth.defaultInstance().loginURL
        
        // open the url with the application delegate function
        application.performSelector(#selector(application.openURL(_:)), withObject: loginURL, afterDelay: 0.1)
        
        // Override point for customization after application launch.
        return true
    }
    
    
    // allow facebook to track installs and app opens
    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject) -> Bool
    {
        if SPTAuth.defaultInstance().canHandleURL(url)
        {
            SPTAuth.defaultInstance().handleAuthCallbackWithTriggeredAuthURL(url, callback: {(error:NSError!, sptSession:SPTSession!) in
                
                if error != nil
                {
                    print("ERROR IN THE SPOTIFY AUTH: \(error.localizedDescription)")
                }
                
                print("I HAVE A SPOTIFY SESSION: \(sptSession.accessToken)")
                // save the session
                SPTAuth.defaultInstance().session = sptSession
            })
            
            return true
        }
        
        return false
        
        //return FBSDKApplicationDelegate.sharedInstance().application(application, openURL: url, sourceApplication: sourceApplication, annotation: annotation)
    }
    
    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        
        // allow facebook to track installs and app opens
        FBSDKAppEvents.activateApp()
    }
    
    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    
}

