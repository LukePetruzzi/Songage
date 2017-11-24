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
        imageView.contentMode = .scaleAspectFit
        
        // set the delegate of the imagePicker
        imagePicker.delegate = self
        
        // ensure no image loaded
        anyImageLoaded = false
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        // update the session if needed
        SpotifyAPIManager.sharedInstance.updateSessionIfNeeded({(error) in
            
            // update the session if no errors
            if error != nil
            {
                let alert = UIAlertController(title: "Error", message: "Error updating Spotify session:\n\(error!.localizedDescription)", preferredStyle: .alert)
                let okAction = UIAlertAction(title: "Okay", style: .default, handler: nil)
                alert.addAction(okAction)
                
                // show the alert to the calling viewController
                self.present(alert, animated: true, completion: nil)
            }
        })
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func addImageButtonTapped(_ sender: UIButton)
    {
        // let the user edit the photo before adding if they want
        imagePicker.allowsEditing = false
        
        let alert = UIAlertController(title: "New Songage", message: "Where do you want the image for your Songage to come from?", preferredStyle: .actionSheet)
        
        let cameraAction = UIAlertAction(title: "Take a Photo", style: .default, handler: {(cameraAction) -> Void in
            
            // take a photo
            self.imagePicker.sourceType = .camera
            self.present(self.imagePicker, animated: true, completion: nil)
        })
        let libraryAction = UIAlertAction(title: "Photo from Library", style: .default, handler: {(libraryAction) -> Void in
            
            // choose a photo from library
            self.imagePicker.sourceType = .photoLibrary
            self.present(self.imagePicker, animated: true, completion: nil)
        })
        let albumAction = UIAlertAction(title: "Photo from Album", style: .default, handler: {(albumAction) -> Void in
            
            // choose a photo from album
            self.imagePicker.sourceType = .savedPhotosAlbum
            self.present(self.imagePicker, animated: true, completion: nil)
        })
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alert.addAction(cameraAction)
        alert.addAction(libraryAction)
        alert.addAction(albumAction)
        alert.addAction(cancelAction)
        
        // present the controller
        self.present(alert, animated: true, completion: nil)
    }
    
    // finished picking the image from the controller
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any])
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
        
        dismiss(animated: true, completion: nil)
    }
    
    // just get rid of the imagePickerView if user cancels
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController)
    {
        dismiss(animated: true, completion: nil)
    }
    
    // begin Songage creation. Send imageData to Clarifai
    @IBAction func createSongageTapped(_ sender: UIButton)
    {
        // dont make the request unless an image is picked
        if anyImageLoaded == true
        {
            // disable button until completion function is finished
            createSongageButton.isEnabled = false
            
            // format the image to jpeg
            let jpeg = UIImageJPEGRepresentation(self.imageView.image!, 0.9)!
            
            // get the tags for the image
            ClarifaiAPIManager.sharedInstance.getTagsForImage(jpeg, presentingViewController: self, completion: getTagsComplete)
        }
        else // no image loaded yet
        {
            // create and show an alert that the user has no image selected
            let alert = UIAlertController(title: "No Image", message: "To create a Songage, supply an image!", preferredStyle: .actionSheet)
            let okAction = UIAlertAction(title: "Okay", style: .default, handler: nil)
            alert.addAction(okAction)
            self.present(alert, animated: true, completion: nil)
        }
        
    }
    
    // after the button has been tapped
    func getTagsComplete(_ tags: [String]?, error: NSError?)
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
        createSongageButton.isEnabled = true
    }
    
    func searchForTracksComplete(_ returnedSongs: [(trackName:String, trackID:String)]?, error: NSError?)
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
                        DispatchQueue.global(priority: Int(DispatchQoS.QoSClass.userInitiated.rawValue)).async
                        {
                            
                            let dispatchGroup = DispatchGroup()
                            for track in returnedTracks! // get album cover for every track
                            {
                                // enter the group
                                dispatchGroup.enter()
                                
                                self.requestImage(track.album.largestCover.imageURL, completion: {(image) in
                                    
                                    // add album cover to the images
                                    albumCovers.append(image!)
                                    albumObtainedCount += 1
                                    
                                    if (albumObtainedCount == returnedTracks?.count)   {
                                        // set the covers to what was returned
                                        SongsList.sharedInstance.setAlbumCovers(albumCovers)
                                        // present the next view controller
                                        self.present(PlayReturnedSongsViewController(), animated: true, completion: nil)
                                        
                                        // remove the loading overlay because done loading
                                        self.removeLoadingOverlay()
                                    }
                                    
                                    dispatchGroup.leave()
                                })
                                
                                dispatchGroup.wait(timeout: DispatchTime.distantFuture)
                            }
                        }
                        
                    }
                })
            }
        })
    }
    
    // reset the variables
    fileprivate func resetMusixCalls()
    {
        musixCallsMadeSoFar = 0
        songsIDsForThisImage = []
    }
}
