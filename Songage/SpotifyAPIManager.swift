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
    
    // Audio player for spotify stuff
    var player:SPTAudioStreamingController?
    
    // Spotify constants
    let kClientID = "2bb2c1d0c40c47e4940855b6b1f56112"
    let kCallbackURL = "songage://returnAfterLogin"
    let kTokenSwapURL = "https://arcane-shelf-78119.herokuapp.com/swap"
    let kTokenRefreshServiceURL = "https://arcane-shelf-78119.herokuapp.com/refresh"
    
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
    
    func setupPlayerWithQueueOfSongs(tracksToQueue:[SPTTrack], completion:((error:NSError?) -> Void))
    {
        
        print("TRACKS RECEIVED. FIRST ONE: \(tracksToQueue[0].name)")
        
        // if the player hasn't been initialized... do so
        if self.player == nil {
            print("PLAYER INITIALIZED")
            
            self.player = SPTAudioStreamingController(clientId: SPTAuth.defaultInstance().clientID)
        }
        
        print("PLAYER HAS THIS MANY TRACKS IN IT (SHOULD BE ZERO): \(self.player?.accessibilityElementCount())")
        
        
        if !(player?.loggedIn)!
        {
            self.player?.loginWithSession(SPTAuth.defaultInstance().session, callback: {(error:NSError!) -> Void in
                
                if error != nil
                {
                    completion(error: error)
                }
                else // no error. play the tracks
                {
                    var trackURIs:[NSURL] = []
                    // get the uris for all the tracks
                    for track in tracksToQueue {
                        trackURIs.append(track.uri)
                    }
                    
                    
                    print("STARTED REPLACE URIS FUNCTION WITH NEWLY LOGGEDIN PLAYER")
                    // get the uris into the player and ready to play
                    self.player?.replaceURIs(trackURIs, withCurrentTrack: 0, callback: {(error:NSError!) -> Void in
                        
                        if error != nil{
                            completion(error: error)
                        }
                        else
                        {
                            print("SHOULD HAVE SET UP THE TRACKS")
                            completion(error: nil)
                        }
                    })
                }
            })
        }
        else// session already logged in. just get the tracks
        {
            var trackURIs:[NSURL] = []
            // get the uris for all the tracks
            for track in tracksToQueue {
                trackURIs.append(track.uri)
            }
            
            print("STARTED REPLACE URIS FUNCTION WITH ALREADY LOGGED IN PLAYER")

            // get the uris into the player and ready to play
            self.player?.replaceURIs(trackURIs, withCurrentTrack: 0, callback: {(error:NSError!) -> Void in
                
                if error != nil{
                    completion(error: error)
                }
                else
                {
                    print("SHOULD HAVE SET UP THE TRACKS")
                    completion(error: nil)
                }
            })
        }
    }
    
    // refresh the player by deleting its songs in its indices.
    func renewPlayer(completion:((error:NSError?) -> Void))
    {
        // if the player hasn't been initialized... do so
        if player == nil {
            print("PLAYER INITIALIZED")
            
            player = SPTAudioStreamingController(clientId: SPTAuth.defaultInstance().clientID)
        }
        
        player?.stop({(error) in
            
            if error != nil {
                completion(error: error)
                return
            }
            print("PLAYER REFRESHED")
        })
    }
    
    func playTrackWithSentIndex(indexOfTrack:Int32, completion:((error:NSError?) -> Void))
    {
        player?.playURIsFromIndex(indexOfTrack, callback: {(error) in
            
            if error != nil
            {
                completion(error: error)
            }
            else{
                print("SONG SHOULD BE PLAYING!!!")
            }
        })
    }
    
    func getSpotifyTracks(spotifyTrackIDs:[String], completion: (returnedTracks:[SPTTrack]?, error:NSError?) -> Void)
    {
        // format the IDs into URIs to send to Spotify
        var trackURIs:[NSURL] = []
        
        for trackID in spotifyTrackIDs {
            trackURIs.append(NSURL(string: "spotify:track:\(trackID)")!)
        }
        
        // if doesnt work prolly cuz of trackURIs??
        SPTTrack.tracksWithURIs(trackURIs, session: SPTAuth.defaultInstance().session, callback: {(error:NSError!, trackObject:AnyObject!) -> Void in
            
            // check for errors
            if error != nil
            {
                completion(returnedTracks: nil, error: error)
                return
            }
            else if trackObject != nil// no errors
            {
                // get the tracks and return them
                let tracksToReturn:[SPTTrack] = trackObject as! [SPTTrack]
                
                completion(returnedTracks: tracksToReturn, error: nil)
            }
            else // the tracks didnt return for some reason
            {
                completion(returnedTracks: nil, error: NSError(domain: "These numbers spell \"Boobs\":", code: 80085, userInfo: nil))
            }
        })
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
                        print("SPOTIFY SESSION UPDATED SUCCESSFULLY!")
                        SPTAuth.defaultInstance().session = newSession
                        
                        completion(error: nil)
                    }
                    else
                    {
                        print("ERROR IN SPOTIFY SESSION RENEWAL: \(error.localizedDescription)")
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
                print("SPOTIFY SESSION IS STILL VALID!")
                SPTAuth.defaultInstance().session = oldSession
                completion(error: nil)
            }
        }
    }
    
    
}