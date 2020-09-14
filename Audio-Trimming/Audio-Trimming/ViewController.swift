//
//  ViewController.swift
//  Audio-Trimming
//
//  Created by Alex Paul on 9/14/20.
//  Copyright © 2020 Alex Paul. All rights reserved.
//

import UIKit
import AVFoundation
import AVKit

class ViewController: UIViewController {
  
  private var player: AVAudioPlayer?
  
  override func viewDidLoad() {
    super.viewDidLoad()
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    playAudio()
    //playFromBundle()
  }
  
  
  func playAudio() {
    
    guard let url = URL(string: "https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3") else {
      return
    }
    do {
      
      let data = try Data(contentsOf: url)
      
      //player = try AVAudioPlayer(contentsOf: url)
      player = try AVAudioPlayer(data: data)
      player?.prepareToPlay()
      player?.play()
    } catch {
      print("failed to play with error: \(error)")
    }
    
    
    //    do {
    //      try AVAudioSession.sharedInstance().setCategory(.playback)
    //
    //      player = try AVAudioPlayer(contentsOf: url)
    //      player?.prepareToPlay()
    //      player?.play()
    //    } catch {
    //      print("audio playback error: \(error)")
    //    }
  }
  
  func playFromBundle() {
    guard let url = Bundle.main.url(forResource: "timeless", withExtension: ".mp3") else {
      fatalError("resource not found")
    }
    
    do {
      try AVAudioSession.sharedInstance().setCategory(.playback)
      player = try AVAudioPlayer(contentsOf: url)
      player?.play()
    } catch {
      print("audio playback error: \(error)")
    }
    
  }
  
  
}

