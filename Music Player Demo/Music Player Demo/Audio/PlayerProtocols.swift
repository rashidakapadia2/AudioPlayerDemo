//
//  Protocol.swift
//  Music Player Demo
//
//  Created by Webwerks on 02/06/22.
//

import Foundation

///MARK:- Protocol - Delegate for Service Class
protocol PlayerServicesDelegate {
    
    //MARK:- Notify next song automatically playing
    func notifyNextSongPlayed(position: Int)
    
    //MARK:- AutoMate the update of UIView per second
    func updateUIView()
    
    //MARK: Error
    func getErrorMessage(error: PlayerError)
}

///MARK: Protocol - Delegate For Error Handling
protocol PlayerMangerDelegate {
    func getErrorMessage(error: PlayerError)
}


