//
//  Manager.swift
//  Music Player Demo
//
//  Created by Webwerks on 01/06/22.
//

import Foundation

struct CurrentPlayer {
    var url:URL?
    var totalDuration:TimeInterval
    var position: FilePresentInList
}

enum FilePresentInList{
    case isPresent(position :Int)
    case notPresent
}

class PlayerService{
    
    //MARK: Static Instance
    static let shared = PlayerService()
    
    init() {
        manager.delegate = self
    }
    
    //MARK: Properties
    let manager = PlayerManager.shared
    
    //MARK: Private Properties
    private var ListOfFileURL:[URL] = [URL]()
    private var playAtTimeInterval: Double = 0
    private var currentPlayingFile: CurrentPlayer?
    private var autoPlayNext:Bool = false
    private var onLoopPlayStatus:Bool = false
    private var autoPlayTimer: Timer!
    private var updateViewTimer: Timer!
    private var onLoopTimer:Timer!
    
    //MARK: Public Properties
    public var delegate: PlayerServicesDelegate?
    
    //MARK: Methods
    //MARK: Methods for Setting File to Manager
    func setCurrentPlayingFile(url: URL,position: FilePresentInList){
        manager.setSongURL(songURL: url)
        manager.prepareSessionAndSong()
        currentPlayingFile = CurrentPlayer(url: url,
                                           totalDuration: manager.getTimeIntervalInSeconds(),
                                           position: position
        )
    }
    
    public func setCurrentPlayingFileAndPlay(url: URL,position: FilePresentInList){
        setCurrentPlayingFile(url: url,position: position)
        playFile()
    }
    
    public func setListOfFileURLToBePlayed(urlList:[URL]){
        ListOfFileURL = urlList
    }
    
    //MARK: Methods for Play and Pause
    public func playFile(){
        manager.playSong()
    }
    
    public func pauseFile(){
        manager.pauseFile()
    }
    
    public func togglePlayPause(){
        manager.actionPlayPause()
    }
    
    public func playNextFile(songId ifplayed:@escaping((Int?) -> Void)){
        var newPosition: Int?
        switch currentPlayingFile?.position {
        case .isPresent(let position):
            if position < ListOfFileURL.count-1  {
                newPosition = position + 1
                playFileUsing(positionFromList: newPosition!)
            }
            else{
                newPosition = 0
                playFileUsing(positionFromList: newPosition!)
            }
            ifplayed(newPosition)
        case .notPresent:
            return
        default:
            break
        }
        ifplayed(nil)
    }
    
    public func playPreviousFile(songId ifplayed:@escaping(Int?) -> Void) {
        var newPosition: Int?
        switch currentPlayingFile?.position {
        case .isPresent(let position):
            if position > 0{
                newPosition = position - 1
                playFileUsing(positionFromList: newPosition!)
            }
            else{
                newPosition = ListOfFileURL.count - 1
                playFileUsing(positionFromList: newPosition!)
            }
            ifplayed(newPosition)
        case .notPresent:
            return
        default:
            break
        }
        ifplayed(nil)
    }
    //MARK: Automate a timer for View
    public func autoUpdateUIView(){
        self.updateViewTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateView), userInfo: nil, repeats: true)
    }
    
    @objc private func updateView(){
        switch getPlayerStatus() {
        case .play:
            delegate?.updateUIView()
        default:
            break
        }
        
    }
    //MARK: Play on Loop
    public func checkOnLoopPlayStatus() -> Bool{
        return onLoopPlayStatus
    }
    
    public func setResetOnLoopPlay(){
        switch onLoopPlayStatus {
        case true:
            resetOnLoop()
        case false:
            setOnLoopActive()
        }
    }
    public func setOnLoopActive(){
        onLoopPlayStatus = true
        autoPlayNext = false
        
        onLoopTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(onLoopPlay), userInfo: nil, repeats: true)
    }
    public func resetOnLoop(){
        onLoopPlayStatus = false
        if updateViewTimer.isValid{
            autoPlayNext = true
        }
        onLoopTimer.invalidate()
    }
    
    @objc private func onLoopPlay(){
        let totalPlayerTime = round(getTotalTimeOfCurrentPlayingFile())
        let completedPlayerTime = round(getcompletedTimeOfCurrentPlayingFile())
        if completedPlayerTime == totalPlayerTime{
            playFileAtSpecificInterval(at: 0)
        }
    }
    
    //MARK: AutoPlaying Files
    public func checkAutoPlayStatus() -> Bool{
        return autoPlayNext
    }
    
    public func setAutoPlayOn(){
        autoPlayNext = true
        self.autoPlayTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(automateTimeSlider), userInfo: nil, repeats: true)
    }
    
    public func setAutoPlayOff(){
        autoPlayNext = false
        autoPlayTimer.invalidate()
    }
    
    @objc private func automateTimeSlider(){
        if autoPlayNext {
            switch manager.playerStatus {
            case .play:
                let totalPlayerTime = round(getTotalTimeOfCurrentPlayingFile())
                let completedPlayerTime = round(getcompletedTimeOfCurrentPlayingFile())
                
                if completedPlayerTime == totalPlayerTime{
                    playNextFile { [self] position in
                        if let position = position {
                            delegate?.notifyNextSongPlayed(position: position)
                        }
                    }
                }
            default:
                break
            }
        }
    }
    //MARK: Play files Methods
    public func playSingleFileUsing(url:URL) {
        setCurrentPlayingFileAndPlay(url: url, position: .notPresent)
        setAutoPlayOff()
    }
    
    public func playFileUsing(positionFromList:Int) {
        if positionFromList < ListOfFileURL.count{
            let newFile = ListOfFileURL[positionFromList]
            setCurrentPlayingFileAndPlay(url: newFile,position: .isPresent(position: positionFromList))
            setAutoPlayOn()
        }
    }
    
    public func playFileAtSpecificInterval(at: TimeInterval){
        manager.setAndPlay(at: at)
    }
    
    //MARK: Get Player Status
    public func getPlayerStatus() -> PlayingStatus {
        return manager.playerStatus
    }
    
    //MARK: Methods for Get Time related values of File playing at
    public func getTotalTimeOfCurrentPlayingFile() -> TimeInterval{
        guard let currentPlayingFile = currentPlayingFile else {
            return 0
        }
        return currentPlayingFile.totalDuration
    }
    
    public func getTotalTimeInHoursMinutesSecondsInString() -> String{
        let time =  currentPlayingFile?.totalDuration ?? 0
        return secondsToHoursMinutesSecondsInString(Int(time))
    }
    
    public func getTotalTimeInHoursMinutesSeconds() -> (Int,Int,Int){
        let time =  currentPlayingFile?.totalDuration ?? 0
        return secondsToHoursMinutesSeconds(Int(time))
    }
    
    public func getcompletedTimeOfCurrentPlayingFile() -> TimeInterval{
        return manager.getcompletedTimeOfCurrentPlayingFile()
    }
    
    public func getCompletedTimeInHoursMinutesSecondsInString() -> String{
        let time = manager.getcompletedTimeOfCurrentPlayingFile()
        return secondsToHoursMinutesSecondsInString(Int(time))
    }
    
    public func getCompletedTimeInHoursMinutesSeconds() -> (Int,Int,Int){
        let time = manager.getcompletedTimeOfCurrentPlayingFile()
        return secondsToHoursMinutesSeconds(Int(time))
    }
    
    private func secondsToHoursMinutesSecondsInString(_ seconds: Int) -> String{
        let h = seconds / 3600
        let m = (seconds % 3600) / 60
        let s = (seconds % 3600) % 60
        var timeString = h>0 ? "\(h):" : ""
        timeString = timeString + (m<10 ? "0" : "") + "\(m):"
        timeString = timeString + (s<10 ? "0" : "") + "\(s)"
        return timeString
    }
    private func secondsToHoursMinutesSeconds(_ seconds: Int) -> (Int, Int, Int) {
        return (seconds / 3600, (seconds % 3600) / 60, (seconds % 3600) % 60)
    }
}

extension PlayerService: PlayerMangerDelegate{
    func getErrorMessage(error: PlayerError) {
        switch error {
        case .setCategoryError(message: let message),
             .setActiveError(message: let message),
             .generalError(message: let message):
            delegate?.getErrorMessage(error: .generalError(message: message))
        }
    }
    
    
}
