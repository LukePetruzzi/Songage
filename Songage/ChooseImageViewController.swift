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
    
    // has an image been added yet?
    var anyImageLoaded = false
    
    // an array that can be added to on subsequent calls of the MusixmatchAPI
    var songsIDsForThisImage:[String] = []
    // number of times songs will come in
    var numberOfMusixCallsForThisImage = 0
    // tell how many calls been made so far
    var musixCallsMadeSoFar = 0
    
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        // make it so the image goes in real good
        imageView.contentMode = .ScaleAspectFit
        
        // set the delegate of the imagePicker
        imagePicker.delegate = self
        
        // ensure no image loaded
        anyImageLoaded = false
    }
    
    override func viewWillAppear(animated: Bool)
    {
        // update the session if needed
        SpotifyAPIManager.sharedInstance.updateSessionIfNeeded({(error) in
            
            // update the session if no errors
            if error != nil
            {
                let alert = UIAlertController(title: "Error", message: "Error updating Spotify session:\n\(error!.localizedDescription)", preferredStyle: .Alert)
                let okAction = UIAlertAction(title: "Okay", style: .Default, handler: nil)
                alert.addAction(okAction)
                
                // show the alert to the calling viewController
                self.presentViewController(alert, animated: true, completion: nil)
            }
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
        
        // an image has been loaded.
        self.anyImageLoaded = true
        
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
        if anyImageLoaded == true
        {
            // disable button until completion function is finished
            createSongageButton.enabled = false
            
            // format the image to jpeg
            let jpeg = UIImageJPEGRepresentation(self.imageView.image!, 0.9)!
            
            // get the tags for the image
            ClarifaiAPIManager.sharedInstance.getTagsForImage(jpeg, presentingViewController: self, completion: getTagsComplete)
        }
        else // no image loaded yet
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
            
            var i = 0
            // only do 5 API calls (two per hit) or exhaust the tags
            while (i < tags!.count - 1 && i < 10)
            {
                MusixmatchAPIManager.sharedInstance.searchForTracksByLyrics([tags![i],tags![i + 1]],presentingViewController: self, completion: searchForTracksComplete)
                
                // increment i twice... using two tags per call
                i += 2
            }
            
            // let the completion function know the calls are done coming in
            numberOfMusixCallsForThisImage = (i / 2)
        }
        else
        {
            self.showAlertWithError(error!, stringBeforeMessage: "Error analyzing image:")
        }
        
        // reenable the button to create a songage
        createSongageButton.enabled = true
    }
    
    func searchForTracksComplete(returnedSongs: [(trackName:String, trackID:String)]?, error: NSError?)
    {
        if returnedSongs != nil
        {
            print("LIST OF SONGS RETURNED TO COMPLETION: \(returnedSongs!)")
            
            if returnedSongs!.count > 0
            {
                for song in returnedSongs!
                {
                    songsIDsForThisImage.append(song.trackID)
                }
            }
            
            //            if returnedSongs!.count > 0
            //            {
            //                // add the first and most popular song to the songsForThisImage
            //                songsIDsForThisImage.append(returnedSongs![0].trackID)
            //            }
            
            // increment the musix calls
            musixCallsMadeSoFar += 1
            
            // if this was the last call, use all the returned functions
            if musixCallsMadeSoFar == numberOfMusixCallsForThisImage
            {
                getReturnedSongsFromSpotify()
            }
        }
        else // there was some error
        {
            self.showAlertWithError(error!, stringBeforeMessage: "Error searching for songs with lyrics matching your image:")
            
            // reset the calls made so far cuz this thang done broke
            self.resetMusixCalls()
        }
    }
    
    func getReturnedSongsFromSpotify()
    {
        
        print("SONG IDs FOR THIS IMAGE IN THE SPOTIFY CALLER: \(songsIDsForThisImage)")
        
        // get the tracks
        SpotifyAPIManager.sharedInstance.getSpotifyTracks(songsIDsForThisImage, completion: {(returnedTracks:[SPTTrack]?, error:NSError?) in
            // reset the calls made, cuz I don't need them anymore. SUPER MEGA IMPORTANT TO DO THIS WHEN FOR EACH SONGAGE MADE
            self.resetMusixCalls()
            
            // update the session if no errors
            if error != nil
            {
                self.showAlertWithError(error!, stringBeforeMessage: "Error retreiving songs from Spotify:")
            }
            else // no error. Tracks returned
            {
                // save the imageView
                SongsList.sharedInstance.setCurrentImage(self.imageView.image!)
                // save the tracks
                SongsList.sharedInstance.setSongsList(returnedTracks!)
                
                
                
                
                // set up the tracks on the player
                SpotifyAPIManager.sharedInstance.setupPlayerWithQueueOfSongs(returnedTracks!, completion: {(error) -> Void in
                    
                    if error != nil {
                        self.showAlertWithError(error!, stringBeforeMessage: "Error putting Spotify tracks in a playable queue: ")
                    }
                    else{
                        //save the album covers
                        var albumCovers:[UIImage] = []
                        var albumObtainedCount = 0
                        
                        // load the albums once at a time
                        dispatch_async(dispatch_get_global_queue(Int(QOS_CLASS_USER_INITIATED.rawValue), 0))
                        {
                            
                            let dispatchGroup = dispatch_group_create()
                            for track in returnedTracks! // get album cover for every track
                            {
                                // enter the group
                                dispatch_group_enter(dispatchGroup)
                                
                                self.requestImage(track.album.largestCover.imageURL, completion: {(image) in
                                    
                                    // add album cover to the images
                                    albumCovers.append(image!)
                                    albumObtainedCount += 1
                                    
                                    if (albumObtainedCount == returnedTracks?.count)   {
                                        // set the covers to what was returned
                                        SongsList.sharedInstance.setAlbumCovers(albumCovers)
                                        // present the next view controller
                                        self.presentViewController(PlayReturnedSongsViewController(), animated: true, completion: nil)
                                        
                                        // remove the loading overlay because done loading
                                        self.removeLoadingOverlay()
                                    }
                                    
                                    dispatch_group_leave(dispatchGroup)
                                })
                                
                                dispatch_group_wait(dispatchGroup, DISPATCH_TIME_FOREVER)
                            }
                        }
                        
                    }
                })
            }
        })
    }
    
    // reset the variables
    private func resetMusixCalls()
    {
        musixCallsMadeSoFar = 0
        songsIDsForThisImage = []
    }
}
