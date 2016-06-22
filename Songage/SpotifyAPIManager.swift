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
    
    
    
}