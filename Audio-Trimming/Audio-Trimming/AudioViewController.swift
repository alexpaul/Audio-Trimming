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

class AudioViewController: UIViewController {
  
  private var player: AVAudioPlayer?
  
  private let m4aAudioFile = "https://dl.espressif.com/dl/audio/ff-16b-2c-44100hz.m4a"
  private let mp3AudioFile = "https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3"
  private let filename = "trimmed.m4a"
  
  override func viewDidLoad() {
    super.viewDidLoad()
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    exportUsingComposition()
  }
  
  func playAudio() {
    guard let url = URL(string: mp3AudioFile) else {
      return
    }
    do {
      let data = try Data(contentsOf: url)
      player = try AVAudioPlayer(data: data)
      player?.prepareToPlay()
      player?.play()
    } catch {
      print("failed to play with error: \(error)")
    }
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
  
  func exportUsingComposition() {
    guard let url = URL(string: mp3AudioFile) else {
      return
    }
    let asset = AVURLAsset(url: url, options: nil) // https://developer.apple.com/documentation/avfoundation/avurlasset
    
    let composition = AVMutableComposition()
    let compositionAudioTrack = composition.addMutableTrack(withMediaType: .audio, preferredTrackID: CMPersistentTrackID(kCMPersistentTrackID_Invalid))
    let sourceAudioTrack = asset.tracks(withMediaType: AVMediaType.audio).first!
    
    do {
      try compositionAudioTrack?.insertTimeRange(CMTimeRange(start: CMTime.zero, duration: asset.duration), of: sourceAudioTrack, at: CMTime.zero)
    } catch {
      print("failed exportUsingComposition: \(error)")
    }
    
    let compatiblePresets = AVAssetExportSession.exportPresets(compatibleWith: composition)
    var preset: String = AVAssetExportPresetPassthrough
    if compatiblePresets.contains(AVAssetExportPresetAppleM4A) {
      preset = AVAssetExportPreset1920x1080 // can change preset here - see doc for more presets
    }
    
    guard let exportSession = AVAssetExportSession(asset: composition, presetName: preset),
          exportSession.supportedFileTypes.contains(.mp4) else {
      fatalError("file type NOT supported")
    }
    
    let documentsDir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    let trimmedFileURL = documentsDir.appendingPathComponent(filename)
    
    if FileManager.default.fileExists(atPath: trimmedFileURL.path) {
      print("file exists")
      try? FileManager.default.removeItem(at: trimmedFileURL)
    } else {
      print("file does not exist")
    }
    
    exportSession.outputURL = trimmedFileURL
    exportSession.outputFileType = .mp4
    
    let startTime = CMTime(value: 0, timescale: 1)
    let stopTime = CMTime(value: 5, timescale: 1)
    exportSession.timeRange = CMTimeRange(start: startTime, end: stopTime)
    
    exportSession.exportAsynchronously {
      print("export complete \(exportSession.status)")
      switch exportSession.status {
      case .cancelled:
        print("cancelled")
      case .failed:
        print("failed \(exportSession.error?.localizedDescription ?? "")")
      case .exporting:
        print("exporting")
      case .completed:
        print("completed")
      case .waiting:
        print("waiting")
      case .unknown:
        print("unknown")
      default:
        print("future case")
      }
    }
  }
  
}

/*
 docs used:
 1. http://www.rockhoppertech.com/blog/ios-trimming-audio-files/
 2. https://www.nuomiphp.com/eplan/en/11860.html (worked)
 */
