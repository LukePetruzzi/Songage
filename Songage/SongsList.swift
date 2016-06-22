//
//  SongsList.swift
//  Songage
//
//  Created by Luke Petruzzi on 6/22/16.
//  Copyright © 2016 Luke Petruzzi. All rights reserved.
//

import Foundation

// class to pass data between the ViewControllers
class SongsList
{
    // Use singleton convention
    class var sharedInstance: SongsList {
        struct Static {
            static var instance:SongsList?
            static var token: dispatch_once_t = 0
        }
        
        dispatch_once(&Static.token)    {
            Static.instance = SongsList()
        }
        return Static.instance!
    }
    
    // list of songs for the current list
    private var currentTracksList:[SPTTrack]?
    
    // image that the user is currently sending
    private var currentImage:UIImage?
    
    func setSongsList(newSongsList:[SPTTrack]?)
    {
        self.currentTracksList = newSongsList
    }
    
    func getSongsList() -> [SPTTrack]?
    {
        return self.currentTracksList
    }
    
    func setCurrentImage(newImage:UIImage)
    {
        self.currentImage = newImage
    }
    
    func getCurrentImage() -> UIImage?
    
    {
        return self.currentImage
    }
    
}