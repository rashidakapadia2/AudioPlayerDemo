//
//  MainViewController.swift
//  Music Player Demo
//
//  Created by Webwerks on 01/06/22.
//

import UIKit
import UniformTypeIdentifiers

class MainViewController: UIViewController{

    //MARK: IBOUTLET
    @IBOutlet weak var playerView: UIView!
    @IBOutlet weak var songCoverPhoto: UIImageView!
    @IBOutlet weak var songName: UILabel!
    @IBOutlet weak var nameAlbumArtist: UILabel!
    @IBOutlet weak var completedTimeInterval: UILabel!
    @IBOutlet weak var totalTimeInterval: UILabel!
    @IBOutlet weak var timeSlider: UISlider!
    @IBOutlet weak var buttonPlayPause: UIButton!
    @IBOutlet weak var songsTableView: UITableView!
    
    // MARK: Properties
    var songsData = [SongModel]()
    var songURLs = [URL]()
    var timer: Timer!
    
    ///MARK: DummyData shared instance
    let dummy = DummyData.dummyData
    
    ///MARK: Player Services shared instance
    var services = PlayerService.shared
    var deviceFile: DeviceFiles = DeviceFile.shared
    //MARK: ViewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpTableData(tableView: songsTableView)
        initialConfiguration()
        services.delegate = self
        self.navigationController?.navigationBar.isHidden = true
    }
    
    
    //MARK: IBActions
    @IBAction func tappedPlayPauseButton(_ sender: UIButton) {
        services.togglePlayPause()
        togglePlayPauseButton()
    }
    @IBAction func tappedPreviousPlayButton(_ sender: UIButton) {
        
        services.playPreviousFile { [self] position in
            if let position = position {
                setUpPlayerView(song: songsData[position])
            }
        }
    }
    @IBAction func tappedNextPlayButton(_ sender: UIButton) {
        services.playNextFile { [self] position in
            if let position = position {
                setUpPlayerView(song: songsData[position])
            }
        }
    }
    @IBAction func onLoopSet(_ sender: UIButton) {
        services.setResetOnLoopPlay()
        sender.tintColor = UIColor.label
        if services.checkOnLoopPlayStatus(){
            sender.tintColor = UIColor.link
        }
    }
    @IBAction func changedSliderValue(_ sender: UISlider) {
        let time = sender.value
        services.playFileAtSpecificInterval(at: TimeInterval(time))
        completedTimeInterval.text = services.getCompletedTimeInHoursMinutesSecondsInString()
    }
    @IBAction func selectSongFromDevice(_ sender: UIButton) {
        deviceFile.getPhoneSongs(vc: self) { [self] fileName in
            songName.text = fileName
            nameAlbumArtist.text = fileName
            songCoverPhoto.image = UIImage(systemName: "music.note.list")
            setUpTimeSlider()
        }
    }
    
    //MARK: Fetching/Creating Data
    private func initialConfiguration(){
        
        //generate Data
        dummy.configureData()
        songsData = dummy.songs
        songURLs = dummy.generateListOfURL()
        services.setListOfFileURLToBePlayed(urlList: songURLs)
        services.setCurrentPlayingFile(url: songURLs[0],
                                       position: .isPresent(position: 0)
        )
        setUpPlayerView(song: dummy.songs[0])
        services.setAutoPlayOn()
        services.autoUpdateUIView()
    }
    
    //MARK: Functions For Button
    private func togglePlayPauseButton(){
        switch services.getPlayerStatus() {
        case .play:
            buttonPlayPause.setImage(UIImage(systemName: "pause.fill"), for: .normal)
        default:
            buttonPlayPause.setImage(UIImage(systemName: "play.fill"), for: .normal)
        }
    }
}

extension MainViewController {
    
    //MARK: setUpPlayerView
    private func setUpPlayerView(song: SongModel){
        songName.text = song.songName
        nameAlbumArtist.text = song.albumName + "-" + song.artistName
        songCoverPhoto.image = UIImage(named: song.songImage)
        setUpTimeSlider()
        togglePlayPauseButton()
    }
    
    //MARK: Timer and Slider Functions
    public func setUpTimeSlider(){
        totalTimeInterval.text = services.getTotalTimeInHoursMinutesSecondsInString()
        completedTimeInterval.text = services.getCompletedTimeInHoursMinutesSecondsInString()
        timeSlider.value = Float(services.getcompletedTimeOfCurrentPlayingFile())
        timeSlider.maximumValue = Float(services.getTotalTimeOfCurrentPlayingFile())
    }
}

//MARK: Table - Delegate & Datasource
extension MainViewController: UITableViewDelegate, UITableViewDataSource{
    
    func setUpTableData(tableView: UITableView){
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: "MusicTableViewCell",
                                 bundle: nil),
                           forCellReuseIdentifier:
                            MusicTableViewCell.identifier)
        tableView.tableFooterView = UIView(frame: .zero) 
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return songsData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MusicTableViewCell",
                                                 for: indexPath
        ) as! MusicTableViewCell
        let song = songsData[indexPath.row]
        cell.updateCellWith(song: song)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let song = songsData[indexPath.row]
        services.setCurrentPlayingFileAndPlay(url: songURLs[indexPath.row],
                                              position: .isPresent(position: indexPath.row))
        setUpPlayerView(song: song)
    }
    
}

extension MainViewController: PlayerServicesDelegate{
    func getErrorMessage(error: PlayerError) {
        switch error {
        case .setCategoryError(message: let message),
             .setActiveError(message: let message),
             .generalError(message: let message):
            self.AlertResponseMessage("Error Occured", message)
        }
    }
    
    func updateUIView() {
        completedTimeInterval.text = services.getCompletedTimeInHoursMinutesSecondsInString()
        totalTimeInterval.text = services.getTotalTimeInHoursMinutesSecondsInString()
        timeSlider.value = Float(services.getcompletedTimeOfCurrentPlayingFile())
        togglePlayPauseButton()
    }
    
    func notifyNextSongPlayed(position: Int) {
        setUpPlayerView(song: songsData[position])
    }
}
