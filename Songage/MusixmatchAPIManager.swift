//
//  MusixmatchAPIManager.swift
//  Songage
//
//  Created by Luke Petruzzi on 6/21/16.
//  Copyright © 2016 Luke Petruzzi. All rights reserved.
//

import Foundation

import Alamofire
import SwiftyJSON

class MusixmatchAPIManager
{
    // Use singleton convention
    class var sharedInstance: MusixmatchAPIManager {
        struct Static {
            static var instance:MusixmatchAPIManager?
            static var token: dispatch_once_t = 0
        }
        
        dispatch_once(&Static.token)    {
            Static.instance = MusixmatchAPIManager()
        }
        return Static.instance!
    }
    
    // apikey for every call of the API
    let apikey:String = "978b1949bd1c33d7708f8ed1b2711a33"
    
    // send in the lyrics to search the API for
    func searchForTracksByLyrics(lyrics:[String], completion: (returnStuff: [String]?, error: NSError?) -> Void)
    {
        //http://api.musixmatch.com/ws/1.1/track.search?q_lyrics=landscape%20water%20nature&apikey=978b1949bd1c33d7708f8ed1b2711a33
        
        var lyricsString:String = ""
        
        for lyric in lyrics
        {
            lyricsString += lyric
            lyricsString += " "
        }
        
        print("LYRICS AS A STRING: \(lyricsString)")
        
        // create the parameters for the request
        let parameters:[String : String] = [
            "q_lyrics": lyricsString,
            "apikey": self.apikey
        ]
        
        // make the request
        let request = Alamofire.request(.GET, "https://api.musixmatch.com/ws/1.1/track.search", parameters: parameters)
        
        print("THIS IS THE URL SENT: \(request.request?.URLString)")
        
        // do things with the reponse
        request.responseJSON { response in
            //            print("REQUEST: \(response.request!)")  // original URL request
            //            print("RESPONSE: \(response.response!.statusCode)") // URL response
            //            print("SERVER DATA: \(response.data!)")     // server data
            //            print("RESULT: \(response.result)")   // result of response serialization
            //
            if response.result.isSuccess
            {
                
                let json = JSON(response.result.value!)
                
                print("JSON OF TRACKSEARCH: \(json)")
                
                let trackList = json["message"]["body"]["track_list"]
                
                var returnTracks:[(trackName:String, trackID:String)] = []
                
                for (key, jsonTrack) in trackList
                {
                    if jsonTrack["track"]["track_spotify_id"].stringValue != ""
                    {
                        print("THIS IS A THING: \(jsonTrack["track"]["track_spotify_id"].stringValue)")
                        returnTracks += [(trackName: jsonTrack["track"]["track_name"].stringValue, trackID: jsonTrack["track"]["track_spotify_id"].stringValue)]
                    }
                }
                
                
                print("THIS IS WHAT I WANT: \(returnTracks)")
                
            }
            else
            {
                print("ERROR IN TRACKSEARCH: \(response.result.error!.localizedDescription)")
                completion(returnStuff: nil, error: response.result.error)
            }
        }
        
    }
    
}