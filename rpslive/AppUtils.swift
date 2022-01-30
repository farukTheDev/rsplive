//
//  AppUtils.swift
//  rpslive
//
//  Created by Ömer Faruk KISIK on 30.01.2022.
//

import Foundation
import AVFoundation

class AudioManager : ObservableObject {
    var audioPlayer : AVAudioPlayer?
    
    func loadAudio(filename: String, ext: String) {
        guard let path = Bundle.main.path(forResource: filename, ofType: ext) else {
            print(filename + "is not found")
            return
        }
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: path))
        } catch {
            print("audioPlayer cannot load", path, error)
        }
    }
    
    func playAudio() {
        audioPlayer?.play()
    }
}
