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
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // put the photo in the imageView
        analyzedPhotoImageView.image = SongsList.sharedInstance.getCurrentImage()
        
        // set up the tableView
        self.setupTableView()
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
        return (SongsList.sharedInstance.getSongsList()?.count)!
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        
        
        let cell = songsTableView.dequeueReusableCellWithIdentifier("SpotifyPlayerTableViewCell") as! SpotifyPlayerTableViewCell
        
        
        
        
        return cell
    }
    
}
