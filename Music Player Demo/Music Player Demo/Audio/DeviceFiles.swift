//
//  DeviceFiles.swift
//  Music Player Demo
//
//  Created by Webwerks on 07/06/22.
//

import UIKit
import UniformTypeIdentifiers

protocol DeviceFiles {
    func getPhoneSongs(vc: UIViewController, completion: @escaping((String) -> Void))
}

//MARK: Class for playing Files from Devices present in File Manager
class DeviceFile :NSObject, UIDocumentPickerDelegate, DeviceFiles {
    
    static let shared = DeviceFile()
    
    ///MARK: Player Services shared instance
    var services = PlayerService.shared
    
    var completionHandler: ((String) -> Void)? = nil

    //MARK:Function that displays picker of songs from devices
    func getPhoneSongs(vc: UIViewController, completion: @escaping((String) -> Void)){
        self.completionHandler = completion
        var documentPicker: UIDocumentPickerViewController
        if #available(iOS 14.0, *) {
            let supportedTypes: [UTType] = [UTType.audio]
            documentPicker = UIDocumentPickerViewController(forOpeningContentTypes: supportedTypes)
        } else {
            documentPicker = UIDocumentPickerViewController(documentTypes: ["public.audio"], in: UIDocumentPickerMode.import)
        }
        documentPicker.delegate = self
        vc.present(documentPicker, animated: true, completion: nil)
    }

    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]){
        guard let url = urls.first else { return }
        let name = url.lastPathComponent
        services.playSingleFileUsing(url: url)
        if let completionHandler = completionHandler {
            completionHandler(name)
        }
        }
}

