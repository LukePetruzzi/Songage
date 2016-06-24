//
//  SpotifyPlayerTableViewCell.swift
//  Songage
//
//  Created by Luke Petruzzi on 6/22/16.
//  Copyright © 2016 Luke Petruzzi. All rights reserved.
//

import UIKit

protocol SpotifyPlayerTableViewCellDelegate
{
    func cellWasSelected(cell:SpotifyPlayerTableViewCell)
}

class SpotifyPlayerTableViewCell: UITableViewCell
{
    
    @IBOutlet weak var albumImageView: UIImageView!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var songTitleLabel: UILabel!
    @IBOutlet weak var artistLabel: UILabel!
    @IBOutlet weak var albumNameLabel: UILabel!
    
    // optional delegate to implement protocol
    var delegate:SpotifyPlayerTableViewCellDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
