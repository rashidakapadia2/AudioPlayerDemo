//
//  MusicTableViewCell.swift
//  Music Player Demo
//
//  Created by neosoft on 23/05/22.
//

import UIKit
import AVFoundation


class MusicTableViewCell: UITableViewCell {

    static let identifier = "MusicTableViewCell"
    
    var song: SongModel?

    @IBOutlet weak var songCoverPhoto: UIImageView!
    @IBOutlet weak var songTitle: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
    
    func updateCellWith(song: SongModel) {
        self.song = song
        songCoverPhoto.image = UIImage(named: song.songImage)
        songTitle.text = song.songName
    }
}

