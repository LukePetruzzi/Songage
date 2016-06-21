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
    
    
    
    // Get session from spotify
    func getSessionFromSpotify()
    {
        // set the clientID and stuffs
        SPTAuth.defaultInstance().clientID = "2bb2c1d0c40c47e4940855b6b1f56112"
        // set the redirect URL for after I make a call
        SPTAuth.defaultInstance().redirectURL = NSURL(string: "songage://returnAfterLogin")
        // set the scopes... there's only one needed
        SPTAuth.defaultInstance().requestedScopes = [SPTAuthStreamingScope]
        
        // construct a URL and open it
        let loginURL:NSURL = SPTAuth.defaultInstance().loginURL
        
        SPTAuth.defaultInstance().renewSession(SPTAuth.defaultInstance().session, callback: {(error:NSError!, sptSession:SPTSession!) in
            
            if error != nil
            {
                print("ERROR IN THE SPOTIFY AUTH: \(error.localizedDescription)")
            }
            else
            {
                print("I HAVE A SPOTIFY SESSION: \(sptSession.accessToken)")
                // save the session
                SPTAuth.defaultInstance().session = sptSession
            }
        })
        
    }
    
}
}