//
//  SpotifyAPIManager.swift
//  Songage
//
//  Created by Luke Petruzzi on 6/22/16.
//  Copyright © 2016 Luke Petruzzi. All rights reserved.
//

import Foundation

class SpotifyAPIManager
{
    // Use singleton convention
    class var sharedInstance: SpotifyAPIManager {
        struct Static {
            static var instance:SpotifyAPIManager?
            static var token: dispatch_once_t = 0
        }
        
        dispatch_once(&Static.token)    {
            Static.instance = SpotifyAPIManager()
        }
        return Static.instance!
    }
    
    // Spotify constants
    let kClientID = "2bb2c1d0c40c47e4940855b6b1f56112"
    let kCallbackURL = "songage://returnAfterLogin"
    let kTokenSwapURL = "http://localhost:1234/swap"
    let kTokenRefreshServiceURL = "http://localhost:1234/refresh"
    
    // initialize the manager with everything it needs to be used
    func initializeSpotifyManager()
    {
        let auth = SPTAuth.defaultInstance()
        
        // set all parameters for the login url
        auth.clientID = kClientID
        auth.redirectURL = NSURL(string: kCallbackURL)
        auth.tokenSwapURL = NSURL(string: kTokenSwapURL)
        auth.tokenRefreshURL = NSURL(string: kTokenRefreshServiceURL)
        
        // set the scopes for login... SUPER IMPORTANT THAT I SET ALL THE SCOPES I WANT TO USE
        auth.requestedScopes = [SPTAuthStreamingScope]
        
        // Set the spotify session if necessary
        if let sessionObject:AnyObject = NSUserDefaults.standardUserDefaults().objectForKey("SpotifySession")
        {
            // cast to data object
            let sessionDataObject = sessionObject as! NSData
            
            // get the actual session
            let savedSession = NSKeyedUnarchiver.unarchiveObjectWithData(sessionDataObject) as! SPTSession
            
            auth.session = savedSession
        }
        
        
    }
    
    
    // return the session or nil if there was an error when updating
    func updateSessionIfNeeded(completion:((error:NSError?) -> Void))
    {
        dispatch_async(dispatch_get_global_queue(Int(QOS_CLASS_USER_INITIATED.rawValue), 0))
        {
            // dispatch group to wait for stuff
            let dispatchGroup = dispatch_group_create()
            
            // Refresh the spotify token if necessary
            let userDefaults = NSUserDefaults.standardUserDefaults()
            
            // can force unwrap because user never gets to this screen without a session
            let sessionDataObject:NSData = userDefaults.objectForKey("SpotifySession")! as! NSData
            
            // get the actual session
            let oldSession = NSKeyedUnarchiver.unarchiveObjectWithData(sessionDataObject) as! SPTSession
            
            // update the session if it's no longer valid
            if !oldSession.isValid()
            {
                // allow the the function to wait for the closure
                dispatch_group_enter(dispatchGroup)
                // session is not valid... update it
                SPTAuth.defaultInstance().renewSession(oldSession, callback: {(error:NSError!, newSession:SPTSession!) -> Void in
                    
                    // no error. update the session
                    if error == nil
                    {
                        // save the session
                        let sessionData = NSKeyedArchiver.archivedDataWithRootObject(newSession)
                        userDefaults.setObject(sessionData, forKey: "SpotifySession")
                        userDefaults.synchronize()
                        
                        // update my session
                        print("SESSION UPDATED SUCCESSFULLY!")
                        SPTAuth.defaultInstance().session = newSession
                        
                        completion(error: nil)
                    }
                    else
                    {
                        print("ERROR IN SESSION RENEWAL: \(error.localizedDescription)")
                        // session not renewed
                        completion(error: error)
                    }
                    
                    // let wait stop waiting
                    dispatch_group_leave(dispatchGroup)
                })
                // wait for closure to finish
                dispatch_group_wait(dispatchGroup, DISPATCH_TIME_FOREVER)
            }
            else // old session is still valid. Return and use it
            {
                print("SESSION IS STILL VALID!")
                SPTAuth.defaultInstance().session = oldSession
                completion(error: nil)
            }
        }
    }
    
}