//
//  PlayerManager.swift
//  Audio Manager
//
//  Created by neosoft on 25/05/22.
//

import Foundation
import AVFoundation

//MARK: enum for errors in player
enum PlayerError{
    case setCategoryError(message:String)
    case setActiveError(message:String)
    case generalError(message:String)
}


//MARK: enum to define in which condition/mode is audio player
enum PlayingStatus{
    case play,pause,stop
}

//MARK: Player Manager Class
class  PlayerManager {
    
    //MARK: shared instance of PlayerManager class
    static let shared =  PlayerManager()
    
    //MARK: Private Properties
    private var songURL:URL?
    public var player:AVPlayer?
     var playerItem:AVPlayerItem?
    private var playAtTimeInterval: Double = 0
    
    //MARK: Public Properties
    public var playerStatus: PlayingStatus = .stop
    public var delegate: PlayerMangerDelegate?
    
    //MARK: Functions
    public func setSongURL(songURL: URL?){
        self.songURL = songURL
    }
//    
//    public func setSongModel(song: SongModel){
//        songURL = Bundle.main.url(forResource: song.fileName, withExtension: song.fileType)
//    }
//    
   public func prepareSessionAndSong(){
        guard let songURL = songURL
        else{
            return
        }
        setAVSessionCategory(category: .playback)
        setAVSessionActive(wantToset: true, options: .notifyOthersOnDeactivation)
    
        //checking if file is compatible
        let asset = AVURLAsset(url: songURL)
        guard asset.isComposable else {
            delegate?.getErrorMessage(error: .generalError(message: "File is not Supported"))
            playerItem = nil
            player = nil
            return
        }
        playerItem = AVPlayerItem(url: songURL)
        player = AVPlayer(playerItem: playerItem)
    }
    //
   public func setAVSessionCategory(category: AVAudioSession.Category){
        do {
            try AVAudioSession.sharedInstance().setCategory(category)
        } catch let error {
            delegate?.getErrorMessage(error: .setCategoryError(message: error.localizedDescription))
        }
        
    }
    //
   public func setAVSessionActive(wantToset:Bool,options: AVAudioSession.SetActiveOptions){
        do {
            try AVAudioSession.sharedInstance().setActive(wantToset, options: options)
        } catch let error {
            delegate?.getErrorMessage(error: .setActiveError(message: error.localizedDescription))
        }
        
    }
    //MARK: Function about Play, Pause
   public func actionPlayPause() {
        switch playerStatus{
        case .play:
            pauseFile()
        case .pause:
            playSong()
        case .stop:
            playSong()
        }
    }
    
   public func playSong()  {
        guard var _ = playerItem , let player = player else{
            return
        }
        player.play()
        playerStatus = .play
    }
    
   public func pauseFile()  {
        guard  let playerItem = playerItem  else {
            return
        }
        let duration : CMTime = playerItem.currentTime()
        let seconds : Float64 = CMTimeGetSeconds(duration)
        playAtTimeInterval = seconds
        player?.pause()
        playerStatus = .pause
    }
    
    
    
    //Mark: Function returns total Time of file.
   public func getTimeIntervalInSeconds() -> TimeInterval{
        guard  let playerItem = playerItem  else {
            return 0
        }
        let duration : CMTime = playerItem.asset.duration
        let seconds : Float64 = CMTimeGetSeconds(duration)
        return seconds
    }
    
    public func getcompletedTimeOfCurrentPlayingFile() -> TimeInterval{
        guard let playerItem = playerItem else {
            return 0
        }
        let duration : CMTime = playerItem.currentTime()
        let seconds : Float64 = CMTimeGetSeconds(duration)
        return seconds
    }
    
    //MARK: Function to play file at certain point of time
    
    public func setAndPlay(at timeIntervalInSeconds: TimeInterval){
        setPlayAtTimeInterval(at: timeIntervalInSeconds)
        switch playerStatus{
        case .play:
            if player?.rate == 0
            {
                player?.play()
            }
        case .pause, .stop:
            break
        }
    }
    
    //MARK: Set playing position(Time interval at which currently song is)
    public func setPlayAtTimeInterval(at time: Double){
        playAtTimeInterval = time
        let seconds : Int64 = Int64(playAtTimeInterval)
        let targetTime:CMTime = CMTimeMake(value: seconds, timescale: 1)
        player?.seek(to: targetTime)
    }
}

