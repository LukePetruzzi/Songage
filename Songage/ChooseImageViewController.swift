//
//  ChooseImageViewController.swift
//  Songage
//
//  Created by Luke Petruzzi on 6/20/16.
//  Copyright © 2016 Luke Petruzzi. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class ChooseImageViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    // create all outlets
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var createSongageButton: UIButton!
    
    // create an image picker to use when add photo button is tapped
    let imagePicker = UIImagePickerController()
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        // set the delegate of the imagePicker
        imagePicker.delegate = self
        
        // test musixmatch
        MusixmatchAPIManager.sharedInstance.searchForTracksByLyrics(["happy"], completion: {(returnStuff, error) in
            
        })
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func addImageButtonTapped(sender: UIButton)
    {
        // let the user edit the photo before adding if they want
        imagePicker.allowsEditing = false
        
        let alert = UIAlertController(title: "New Songage", message: "Where do you want the image for your Songage to come from?", preferredStyle: .ActionSheet)
        
        let cameraAction = UIAlertAction(title: "Take a Photo", style: .Default, handler: {(cameraAction) -> Void in
            
            // take a photo
            self.imagePicker.sourceType = .Camera
            self.presentViewController(self.imagePicker, animated: true, completion: nil)
        })
        let libraryAction = UIAlertAction(title: "Photo from Library", style: .Default, handler: {(libraryAction) -> Void in
            
            // choose a photo from library
            self.imagePicker.sourceType = .PhotoLibrary
            self.presentViewController(self.imagePicker, animated: true, completion: nil)
        })
        let albumAction = UIAlertAction(title: "Photo from Album", style: .Default, handler: {(albumAction) -> Void in
            
            // choose a photo from album
            self.imagePicker.sourceType = .SavedPhotosAlbum
            self.presentViewController(self.imagePicker, animated: true, completion: nil)
        })
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
        
        alert.addAction(cameraAction)
        alert.addAction(libraryAction)
        alert.addAction(albumAction)
        alert.addAction(cancelAction)
        
        // present the controller
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    // finished picking the image from the controller
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject])
    {
        if let pickedImage = info[UIImagePickerControllerEditedImage] as? UIImage
        {
            // fit the image to the view and add it
            imageView.image = pickedImage
        }
        else if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage
        {
            // fit the image to the view and add it
            imageView.image = pickedImage
        }
        
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    // just get rid of the imagePickerView if user cancels
    func imagePickerControllerDidCancel(picker: UIImagePickerController)
    {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    // begin Songage creation. Send imageData to Clarifai
    @IBAction func createSongageTapped(sender: UIButton)
    {
        // dont make the request unless an image is picked
        if imageView.image! != UIImage(named: "defaultImage")
        {
            // disable button until completion function is finished
            createSongageButton.enabled = false
            
            // format the image to jpeg
            let jpeg = UIImageJPEGRepresentation(self.imageView.image!, 0.9)!
            
            // get the tags for the image
            ClarifaiAPIManager.sharedInstance.getTagsForImage(jpeg, presentingViewController: self, completion: getTagsComplete)
        }
        else
        {
            // create and show an alert that the user has no image selected
            let alert = UIAlertController(title: "No Image", message: "To create a Songage, supply an image!", preferredStyle: .ActionSheet)
            let okAction = UIAlertAction(title: "Okay", style: .Default, handler: nil)
            alert.addAction(okAction)
            self.presentViewController(alert, animated: true, completion: nil)
        }
        
    }
    
    // after the button has been tapped
    func getTagsComplete(tags: [String]?, error: NSError?)
    {
        if tags != nil
        {
            print("Returned tags: \(tags!)")
        }
        else
        {
            print("ERROR IN TAGS COMPLETE: \(error!.localizedDescription)")
            
            let alert = UIAlertController(title: "Error", message: error!.localizedDescription, preferredStyle: .Alert)
            let okAction = UIAlertAction(title: "Okay", style: .Default, handler: nil)
            alert.addAction(okAction)
            
            // show the alert to the calling viewController
            self.presentViewController(alert, animated: true, completion: nil)
        }
        
        
        // reenable the button to create a songage
        createSongageButton.enabled = true
    }
    
}
