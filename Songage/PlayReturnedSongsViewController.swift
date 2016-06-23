//
//  PlayReturnedSongsViewController.swift
//  Songage
//
//  Created by Luke Petruzzi on 6/22/16.
//  Copyright © 2016 Luke Petruzzi. All rights reserved.
//

import UIKit

class PlayReturnedSongsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var analyzedPhotoImageView: UIImageView!
    @IBOutlet weak var songsTableView: UITableView!
    
    // the tracks 
    // get all the tracks for this list of songIDs
    var tracks:[SPTTrack]?
    // get all the album covers
    var albumCovers:[UIImage] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // set up the tableView
        self.setupTableView()
        
        // make it so the image goes in real good
        analyzedPhotoImageView.contentMode = .ScaleAspectFit
        // put the photo in the imageView
        analyzedPhotoImageView.image = SongsList.sharedInstance.getCurrentImage()
        tracks = SongsList.sharedInstance.getSongsList()
        albumCovers = SongsList.sharedInstance.getAlbumCovers()
        print("THIS IS THE AMOUNT OF ALBUM COVERS: \(albumCovers.count)")

    }
    
    override func viewWillAppear(animated: Bool)
    {
        
        // update the session if needed
        SpotifyAPIManager.sharedInstance.updateSessionIfNeeded({(error) in
            
            // update the session if no errors
            if error != nil
            {
                self.showAlertWithError(error!, stringBeforeMessage: "Error updating spotify session:")
            }
        })
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setupTableView()
    {
        // make the table's delegate and dataSource itself
        songsTableView.delegate = self
        songsTableView.dataSource = self
        
        // register my custom nib
        songsTableView.registerNib(UINib(nibName: "SpotifyPlayerTableViewCell", bundle: nil), forCellReuseIdentifier: "SpotifyPlayerTableViewCell")
        
        // set the height
        songsTableView.rowHeight = CGFloat(85)
        
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return SongsList.sharedInstance.getSongsList().count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let cell = songsTableView.dequeueReusableCellWithIdentifier("SpotifyPlayerTableViewCell") as! SpotifyPlayerTableViewCell
        
        // get the data for the cell
        if tracks != nil
        {
            let currentTrack = tracks![indexPath.row]
            
            cell.songTitleLabel.text = currentTrack.name
            cell.artistLabel.text = currentTrack.artists[0] as? String
            cell.albumNameLabel.text = currentTrack.album.name
            cell.albumImageView.image = albumCovers[indexPath.row]
        }
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        // if user has been away, the session may be old
        SpotifyAPIManager.sharedInstance.updateSessionIfNeeded({(error) in
            
            // update the session if no errors
            if error != nil{
                // show the error if there is one
                self.showAlertWithError(error!, stringBeforeMessage: "Error updating spotify session: ")
            }
        })
        
        print("TRACK SELECTED: \(tracks![indexPath.row].name)")

        // play the track at the index
        SpotifyAPIManager.sharedInstance.playTrackWithSentIndex(Int32(indexPath.row), completion: {(error) in
            
            if error != nil{
                self.showAlertWithError(error!, stringBeforeMessage: "Error playing song:")
            }
        })
    }
    
    @IBAction func newSongageButtonTapped(sender: UIButton)
    {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    override func viewDidDisappear(animated: Bool)
    {
        // refresh the player for the next go around
        SpotifyAPIManager.sharedInstance.renewPlayer({(error) in
            if error != nil{
                self.showAlertWithError(error!, stringBeforeMessage: "Error refreshing the player:")
            }
        })
    }
    
}
