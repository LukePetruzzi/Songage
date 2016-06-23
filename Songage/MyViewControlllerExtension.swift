//
//  UIImageViewURLExtension.swift
//  Songage
//
//  Created by Luke Petruzzi on 6/22/16.
//  Copyright © 2016 Luke Petruzzi. All rights reserved.
//

import Foundation
import UIKit

extension UIViewController
{
    public func requestImage(imageUrl: NSURL, completion: (image:UIImage?) -> Void)
    {
        let session = NSURLSession.sharedSession()
        let request = NSURLRequest(URL: imageUrl)
        
        dispatch_async(dispatch_get_global_queue(Int(QOS_CLASS_USER_INITIATED.rawValue), 0))
        {
            // dispatch group to wait for stuff
            let dispatchGroup = dispatch_group_create()
            
            // allow the the function to wait for the closure
            dispatch_group_enter(dispatchGroup)
            let dataTask = session.dataTaskWithRequest(request, completionHandler: {(data:NSData?, response:NSURLResponse?, error:NSError?) -> Void in
                
                if error != nil
                {
                    print("Error getting image: \(error?.localizedDescription)")
                }
                else // no error. use the data
                {
                    completion(image: UIImage(data: data!))
                }
                
                // let wait stop waiting
                dispatch_group_leave(dispatchGroup)
            })
            dataTask.resume()
            
            // wait for closure to finish
            dispatch_group_wait(dispatchGroup, DISPATCH_TIME_FOREVER)
        }
    }
    
    func showAlertWithError(error:NSError, stringBeforeMessage:String?)
    {
        let alert = UIAlertController(title: "Error", message: "\(stringBeforeMessage)\n\(error.localizedDescription)", preferredStyle: .Alert)
        let okAction = UIAlertAction(title: "Okay", style: .Default, handler: nil)
        alert.addAction(okAction)
        
        // show the alert to the calling viewController
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
}