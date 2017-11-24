//
//  UIImageViewURLExtension.swift
//  Songage
//
//  Created by Luke Petruzzi on 6/22/16.
//  Copyright © 2016 Luke Petruzzi. All rights reserved.
//

import Foundation
import UIKit

public let LOADING_OVERLAY_VIEW_TAG = 987432

extension UIViewController
{
    public func requestImage(_ imageUrl: URL, completion: @escaping (_ image:UIImage?) -> Void)
    {
        let session = URLSession.shared
        let request = URLRequest(url: imageUrl)
        
        DispatchQueue.global(qos: DispatchQoS.QoSClass.userInitiated).async
        {
            // dispatch group to wait for stuff
            let dispatchGroup = DispatchGroup()
            
            // allow the the function to wait for the closure
            dispatchGroup.enter()
            let dataTask = session.dataTask(with: request, completionHandler: {(data:Data?, response:URLResponse?, error:NSError?) -> Void in
                
                if error != nil
                {
                    self.showAlertWithError(error!, stringBeforeMessage: "Error getting album image:")
                }
                else // no error. use the data
                {
                    completion(UIImage(data: data!))
                }
                
                // let wait stop waiting
                dispatchGroup.leave()
                } as! (Data?, URLResponse?, Error?) -> Void)
            dataTask.resume()
            
            // wait for closure to finish
            dispatchGroup.wait(timeout: DispatchTime.distantFuture)
        }
    }
    
    func showAlertWithError(_ error:NSError, stringBeforeMessage:String?)
    {
        var preErrorString = stringBeforeMessage
        
        if stringBeforeMessage == nil{
            preErrorString = ""
        }
        
        let alert = UIAlertController(title: "Error", message: "\(preErrorString!)\n\(error.localizedDescription)", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Okay", style: .default, handler: nil)
        alert.addAction(okAction)
        
        // show the alert to the calling viewController
        self.present(alert, animated: true, completion: nil)
        
        // dismiss loading overlay because error
        self.removeLoadingOverlay()
    }
    
    
    // create a loading view overlay
    func addLoadingOverlay()
    {
        let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
        
        // disable user interaction while loading
        appDelegate.window?.isUserInteractionEnabled = false
        
        //add an overlay screen
        let overlayImage = UIImageView(frame: self.view.frame)
        overlayImage.backgroundColor = UIColor.black
        overlayImage.alpha = 0.5
        overlayImage.tag = LOADING_OVERLAY_VIEW_TAG
        
        let loadingSpinner = UIActivityIndicatorView(frame: overlayImage.frame)
        loadingSpinner.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.whiteLarge
        loadingSpinner.startAnimating()
        overlayImage.addSubview(loadingSpinner)
        
        
        return appDelegate.window!.addSubview(overlayImage)
    }
    
    // drop the loading view
    func removeLoadingOverlay()
    {
        
        let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
        
        for view in appDelegate.window!.subviews  {
            if (view.tag == LOADING_OVERLAY_VIEW_TAG)   {
                view.removeFromSuperview()
            }
        }
        
        // reenable user interaction after loading
        appDelegate.window?.isUserInteractionEnabled = true
    }
    
}
