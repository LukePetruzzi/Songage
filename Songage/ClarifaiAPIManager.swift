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
    private var myAccessToken:String?
    
    // check if the manager has a token
    func hasOAuthToken() -> Bool
    {
        if myAccessToken == nil{
            print("This is the NOT TOKEN: \(myAccessToken)")
            return false
        }
        else{
            print("This is the OAUTHTOKEN: \(myAccessToken)")
            return true
        }
    }
    
    // get an auth token from Clarifai
    func getOAuthToken(completion: (error: NSError?) -> Void)
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
            //            print("REQUEST: \(response.request!)")  // original URL request
            //            print("RESPONSE: \(response.response!.statusCode)") // URL response
            //            print("SERVER DATA: \(response.data!)")     // server data
            //            print("RESULT: \(response.result)")   // result of response serialization
            
            if response.result.isSuccess
            {
                
                let json = JSON(response.result.value!)
                
                // save the token
                self.myAccessToken = String(json["access_token"])
                
                print("token saved! token is: \(self.myAccessToken!)")
                completion(error: nil)
            }
            else{
                completion(error: response.result.error)
            }
        }
    }
    
    // pass in a jpeg image, get back Clarifai's tags for the image
    func getTagsForImage(jpeg:NSData, completion: (tags: [String]?, error: NSError?) -> Void)
    {
        dispatch_async(dispatch_get_global_queue(Int(QOS_CLASS_USER_INITIATED.rawValue), 0)) {
            
            let dispatchGroup = dispatch_group_create()
            
            // get an authToken if needed
            if !self.hasOAuthToken()
            {
                
                dispatch_group_enter(dispatchGroup)
                
                self.getOAuthToken({(error) -> Void in
                    if error != nil
                    {
                        print("Error retreiving token from Clarifai: \(error?.localizedDescription)")
                    }
                    // let the dispatchGroup know that the closure is finished
                    dispatch_group_leave(dispatchGroup)
                })
                
                // wait until anAsyncMethod is completed
                dispatch_group_wait(dispatchGroup, DISPATCH_TIME_FOREVER)
            }
            
            
            let parameters:[String : String] = [
                "encoded_data":jpeg.base64EncodedStringWithOptions(.Encoding64CharacterLineLength)
            ]
            let headers:[String : String] = [
                "Authorization": "Bearer \(self.myAccessToken!)"
            ]
            
            print("THIS IS THE TOKEN AT START OF FUNCTION: \(self.myAccessToken)")
            
            let request = Alamofire.request(.POST, "https://api.clarifai.com/v1/tag/", parameters: parameters, encoding: .URL, headers: headers)
            
            var finalValues:[String] = []
            
            // do things with the reponse
            request.responseJSON { response in
                
                if response.result.isSuccess
                {
                    
                    let json = JSON(response.result.value!)
                    
                    print("JSON: \(json)")
                    let tagsForImage = json["results"][0]["result"]["tag"]["classes"]
                    
                    // append all the values of the tags to the array
                    for element in tagsForImage.arrayObject!
                    {
                        finalValues.append(element as! String)
                    }
                    
                    // send back the completion function with the values of the tags
                    completion(tags: finalValues, error: nil)
                }
                else // there was some error. return it.
                {
                    // return the error if there is one
                    completion(tags: nil, error: response.result.error!)
                }
            }
        }
    }
    
    
    
    
}