//
//  ClarifaiAPIManager.swift
//  Songage
//
//  Created by Luke Petruzzi on 6/20/16.
//  Copyright © 2016 Luke Petruzzi. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

class ClarifaiAPIManager
{
    // Use singleton convention
    class var sharedInstance: ClarifaiAPIManager {
        struct Static {
            static var instance:ClarifaiAPIManager?
            static var token: dispatch_once_t = 0
        }
        
        dispatch_once(&Static.token)    {
            Static.instance = ClarifaiAPIManager()
        }
        return Static.instance!
    }
    
    // client id and secret
    let client_id:String = "bsdMzR5PD2b9fgxA9KP-i6rLACY5OeHpcVxcQMbw"
    let client_secret:String = "BtC0WPRZMd2JPGTmpguROKmuWc-9eS22VIvIS1t7"
    
    // saved access token optional
    var myAccessToken:String?
    
    // check if the manager has a token
    func hasOAuthToken() -> Bool
    {
        //hlroopjon
        return false
    }
    
    func getOAuthToken()
    {
        // create the parameters for the request
        let parameters = [
            "client_id": client_id,
            "client_secret": client_secret,
            "grant_type": "client_credentials"
        ]
        
        // send the request
        let request = Alamofire.request(.POST, "https://api.clarifai.com/v1/token/", parameters: parameters)
        
        // do things with the reponse
        request.responseJSON { response in
            print("REQUEST: \(response.request!)")  // original URL request
            print("RESPONSE: \(response.response!.statusCode)") // URL response
            print("SERVER DATA: \(response.data!)")     // server data
            print("RESULT: \(response.result)")   // result of response serialization
            
            if response.result.isSuccess
            {
                
                let json = JSON(response.result.value!)
                
                // save the token
                self.myAccessToken = String(json["access_token"])
                
                print("token saved! token is: \(self.myAccessToken!)")
            }
        }
    }
    
    
    
    
}