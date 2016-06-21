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
    
    private var updatedMyAccessToken:Bool = false
    
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
    
    
    // pass in a jpeg image, get back Clarifai's tags for the image
    func getTagsForImage(jpeg:NSData, presentingViewController:UIViewController?, completion: (tags: [String]?, error: NSError?) -> Void)
    {
        dispatch_async(dispatch_get_global_queue(Int(QOS_CLASS_USER_INITIATED.rawValue), 0)) {
            
            let dispatchGroup = dispatch_group_create()
            
            // get an authToken if needed
            if !self.hasOAuthToken()
            {
                
                dispatch_group_enter(dispatchGroup)
                
                // update the token
                self.getOAuthToken({(thisError) -> Void in
                    if thisError != nil
                    {
                        // call the completion with error from getToken function
                        completion(tags: nil, error: thisError)
                    }
                    // let the dispatchGroup know that the closure is finished
                    dispatch_group_leave(dispatchGroup)
                })
                
                // wait until anAsyncMethod is completed
                dispatch_group_wait(dispatchGroup, DISPATCH_TIME_FOREVER)
                
                // if the token didn't update...
                if !self.updatedMyAccessToken
                {
                    // get out of the getTagsForImage function
                    return
                }
            }
            
            
            let parameters:[String : String] = [
                "encoded_data":jpeg.base64EncodedStringWithOptions(.Encoding64CharacterLineLength)
            ]
            let headers:[String : String] = [
                "Authorization": "Bearer \(self.myAccessToken!)"
            ]
            
            print("THIS IS THE TOKEN AT START OF FUNCTION: \(self.myAccessToken)")
            
            // send the request
            let request = Alamofire.request(.POST, "https://api.clarifai.com/v1/tag/", parameters: parameters, encoding: .URL, headers: headers)
            
            var finalValues:[String] = []
            
            // do things with the reponse
            request.responseJSON { response in
                
                if response.result.isSuccess
                {
                    if response.response!.statusCode == 200
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
                    else if response.response!.statusCode == 401 // There is a problem with the token. Probably too old. Refresh it
                    {
                        dispatch_group_enter(dispatchGroup)
                        
                        // update the token
                        self.getOAuthToken({(thisError) -> Void in
                            if thisError != nil
                            {
                                // call the completion with error from getToken function
                                completion(tags: nil, error: thisError)
                            }
                            // let the dispatchGroup know that the closure is finished
                            dispatch_group_leave(dispatchGroup)
                        })
                        
                        // wait until anAsyncMethod is completed
                        dispatch_group_wait(dispatchGroup, DISPATCH_TIME_FOREVER)
                        
                        if !self.updatedMyAccessToken
                        {
                            // get out of the getTagsForImage function
                            return
                        }
                        else // token updated successfully
                        {
                            // call the function again with the new access token
                            self.getTagsForImage(jpeg, presentingViewController: presentingViewController, completion: completion)
                        }
                    }
                    else // there was some other error that I ain't touching
                    {
                        // return the error if there is one
                        completion(tags: nil, error: response.result.error)
                    }
                }
                else // there was some error. return it.
                {
                    // return the error if there is one
                    completion(tags: nil, error: response.result.error!)
                }
            }
        }
    }
    
    
    // Private helper functions
    // get an auth token from Clarifai
    private func getOAuthToken(completion: (error: NSError?) -> Void)
    {
        // going to call the auth token so let the boolean know
        self.updatedMyAccessToken = false
        
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
            
            if response.result.isSuccess
            {
                
                let json = JSON(response.result.value!)
                
                // save the token
                self.myAccessToken = String(json["access_token"])
                
                print("token saved! token is: \(self.myAccessToken!)")
                
                // update token boolean
                self.updatedMyAccessToken = true
                
                completion(error: nil)
            }
            else
            {
                completion(error: response.result.error)
            }
        }
    }
    
    
    
}