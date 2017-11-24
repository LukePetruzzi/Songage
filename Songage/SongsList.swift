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
    private static var __once: () = {
            Static.instance = SongsList()
        }()
    // Use singleton convention
    struct Static {
        static var instance:SongsList?
        static var token: Int = 0
    }
    class var sharedInstance: SongsList {
        _ = SongsList.__once
        return Static.instance!
    }
    
    // image that the user is currently sending
    fileprivate var currentImage:UIImage = UIImage(named: "defaultImage")!
    // list of songs for the current list
    fileprivate var currentTracksList:[SPTTrack] = []
    // save the pics for the albums
    fileprivate var currentTracksAlbumsCoversList:[UIImage] = []

    
    func setSongsList(_ newSongsList:[SPTTrack])
    {
        self.currentTracksList = newSongsList
    }
    
    func getSongsList() -> [SPTTrack]
    {
        return self.currentTracksList
    }
    
    func setCurrentImage(_ newImage:UIImage)
    {
        self.currentImage = newImage
    }
    
    func getCurrentImage() -> UIImage
    
    {
        return self.currentImage
    }
    
    func setAlbumCovers(_ covers:[UIImage])
    {
        self.currentTracksAlbumsCoversList = covers
    }
    
    func getAlbumCovers() -> [UIImage]
    {
        return self.currentTracksAlbumsCoversList
    }
    
}
