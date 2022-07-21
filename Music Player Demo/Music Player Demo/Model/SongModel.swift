//
//  SongModel.swift
//  Music Player Demo
//
//  Created by neosoft on 24/05/22.
//

import Foundation

struct SongModel {
    var songName: String
    var albumName: String
    var artistName: String
    var songImage: String
    var fileName:String
    var fileType:String = "mp3"
}

class DummyData {
    static let dummyData = DummyData()
    var songs: [SongModel] = [SongModel]()
    func configureData(){
        songs.append(SongModel(songName: "Cheap Thrills",
                               albumName: "Cheap Thrills",
                               artistName: "Sia ft. Sean Paul",
                               songImage: "CheapThrills",
                               fileName: "CheapThrills",
                               fileType: "mp3"))
        songs.append(SongModel(songName: "Roar",
                               albumName: "Prism",
                               artistName: "Katy Perry",
                               songImage: "Roar",
                               fileName: "Roar",
                               fileType: "mp3"))
        songs.append(SongModel(songName: "Goumi",
                               albumName: "Myriam Fares",
                               artistName: "Myriam Fares",
                               songImage: "Goumi",
                               fileName: "GoumiGoumi",
                               fileType: "mp3"))
        songs.append(SongModel(songName: "Khalouni N3ich",
                               albumName: "Arabic Remix (2020)",
                               artistName: "Najwa Farouk",
                               songImage: "KhalouniN3ich",
                               fileName: "KhalouniN3ich",
                               fileType: "mp3"))
        songs.append(SongModel(songName: "Sample Song 2",
                               albumName: "Sample",
                               artistName: "",
                               songImage: "cover",
                               fileName: "sample2",
                               fileType: "mp3"))
        songs.append(SongModel(songName: "Sample Song 3",
                               albumName: "Sample",
                               artistName: "",
                               songImage: "cover",
                               fileName: "playlist",
                               fileType: "mp3"))
    }
    
    func generateListOfURL() -> [URL] {
        var list = [URL]()
        for song in songs {
            if let url = Bundle.main.url(forResource: song.fileName, withExtension: song.fileType) {
                list.append(url)
            }
            else{
                list.append(URL(string: "")!)
            }
        }
        return list
    }
}
