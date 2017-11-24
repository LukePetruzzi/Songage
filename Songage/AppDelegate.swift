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
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool
    {
        // Create the window
        self.window = UIWindow(frame: UIScreen.main.bounds)
        self.window?.makeKeyAndVisible()
        
        // allow facebook to track installs and app opens
        FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
        
        // get my spotify stuff up to speed
        SpotifyAPIManager.sharedInstance.initializeSpotifyManager()
        
        // check for spotify session. If we don't have one yet, send user to the login screen
        let userDefaults = UserDefaults.standard
        if let _:AnyObject = userDefaults.object(forKey: "SpotifySession") as AnyObject?
        {
            // the session is available. Send user to main screen
            self.window?.rootViewController = ChooseImageViewController(nibName: "ChooseImageViewController", bundle: nil)

        }
        else
        {
            // session not available. Send user to spotify login screen
            self.window?.rootViewController = SpotifyLoginViewController(nibName: "SpotifyLoginViewController", bundle: nil)

        }
        
        
        return true
    }
    
    
    // allow facebook to track installs and app opens
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool
    {
        print("HERE's THE SCHEME: \(url.scheme!)")
        print("AND THIS IS THE URL: \(url.absoluteString)")
        
        // handle spotify's schemes
        if url.scheme! == "songage" || url.scheme! == "spotify-action"
        {
            // check that spotify can hendle the URL it was handed
            if SPTAuth.defaultInstance().canHandle(url)
            {
                print("FIRST LAYER INSIDE")
                // let spotify handle the url
                SPTAuth.defaultInstance().handleAuthCallback(withTriggeredAuthURL: url, callback: {(error:NSError!, session:SPTSession!) -> Void in
                    print("WE REALLY INSIDE")
                    // check if there's an error
                    if error != nil
                    {
                        print("WE HAVE N ERROR")
                        print("SPOTIFY AUTHENTIFICATION ERROR IN APPDELEGATE: \(error.localizedDescription)")
                        return // get out of the callback
                    }
                    else // no error!
                    {
                        print("APPARENTLY NO ERROR")
                        // VERY IMPORTANT: CREATE THE SESSION FOR THE FIRST TIME
                        SPTAuth.defaultInstance().session = session
                        
                        // create user defaults stuff so I can access the session forever and ever
                        let userDefaults = UserDefaults.standard
                        let sessionData = NSKeyedArchiver.archivedData(withRootObject: session)
                        userDefaults.set(sessionData, forKey: "SpotifySession")
                        userDefaults.synchronize()
                        
                        // the session is now available and saved. Send user to main screen
                        self.window?.rootViewController = ChooseImageViewController(nibName: "ChooseImageViewController", bundle: nil)
                    }
                } as! SPTAuthCallback)
            }
            else {
                print("SPOTIFY CANT HANDLE THE URL")
            }
        } // handle facebook's schemes
        else if url.scheme == "fb1074091485995679"
        {
            
            return FBSDKApplicationDelegate.sharedInstance().application(application, open: url, sourceApplication: sourceApplication, annotation: annotation)
        }
        
        return false
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        
        // allow facebook to track installs and app opens
        FBSDKAppEvents.activateApp()
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    
}

