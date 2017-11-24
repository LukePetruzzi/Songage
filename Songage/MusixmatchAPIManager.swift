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
    private static var __once: () = {
            Static.instance = MusixmatchAPIManager()
        }()
    // Use singleton convention
    struct Static {
        static var instance:MusixmatchAPIManager?
        static var token: Int = 0
    }
    class var sharedInstance: MusixmatchAPIManager {
        _ = MusixmatchAPIManager.__once
        return Static.instance!
    }
    
    // apikey for every call of the API
    let apikey:String = "978b1949bd1c33d7708f8ed1b2711a33"
    
    // send in the lyrics to search the API for
    func searchForTracksByLyrics(_ lyrics:[String], presentingViewController:UIViewController?, completion: @escaping (_ returnStuff: [(trackName:String, trackID:String)]?, _ error: NSError?) -> Void)
    {
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
            //"s_track_rating": "desc",
            "page_size": String(7),
            "apikey": self.apikey
        ]
        
        // make the request
        let request = Alamofire.request("https://api.musixmatch.com/ws/1.1/track.search", method: .get, parameters: parameters)
        
       // print("THIS IS THE URL SENT: \(request.request?.URLString)")
        
        // do things with the reponse
        request.responseJSON { response in
            
            if response.result.isSuccess
            {
                
                let json = JSON(response.result.value!)
                
               // print("JSON OF TRACKSEARCH: \(json)")
                
                let trackList = json["message"]["body"]["track_list"]
                
                var returnTracks:[(trackName:String, trackID:String)] = []
                

                // parse through the json
                for (_, jsonTrack) in trackList
                {
                    // return onl the songs that have a spotify identifier
                    if jsonTrack["track"]["track_spotify_id"].stringValue != ""
                    {
                        returnTracks += [(trackName: jsonTrack["track"]["track_name"].stringValue, trackID: jsonTrack["track"]["track_spotify_id"].stringValue)]
                    }
                }
                
                // send the tracks back
                completion(returnTracks, nil)
            }
            else
            {
                print("ERROR IN TRACKSEARCH: \(response.result.error!.localizedDescription)")
                completion(nil, response.result.error! as NSError)
            }
        }
        
    }
    
}
