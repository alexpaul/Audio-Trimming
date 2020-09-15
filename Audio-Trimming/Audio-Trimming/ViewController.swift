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
  
  private let m4aAudioFile = "https://dl.espressif.com/dl/audio/ff-16b-2c-44100hz.m4a"
  private let mp3AudioFile = "https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3"
  private let filename = "trimmed.m4a"
  
  override func viewDidLoad() {
    super.viewDidLoad()
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    //playAudio()
    //playFromBundle()
    //exportAsset(with: m4aAudioFile, filename: filename)
    exportUsingComposition()
  }
  
  
  func playAudio() {
    guard let url = URL(string: mp3AudioFile) else {
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
  
  func exportAsset(with urlString: String, filename: String) {
    guard let url = URL(string: urlString) else {
      return
    }
    
    let asset = AVAsset(url: url)
    
    let documentsDir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    let trimmedFileURL = documentsDir.appendingPathComponent(filename)
    
    print("file path: \(trimmedFileURL)")
    
    if asset.isExportable {
      print("is exportable")
    }
    
    if asset.isPlayable {
      print("is playable")
    }
    
    if FileManager.default.fileExists(atPath: trimmedFileURL.absoluteString) {
      print("file exist")
    }
    
    if let exporter = AVAssetExportSession(asset: asset, presetName: AVAssetExportPresetAppleM4A) {
      
      exporter.outputFileType = .m4a
      exporter.outputURL = trimmedFileURL
      
      let duration = CMTimeGetSeconds(asset.duration)
      print("asset duration is \(duration)")
      if duration < 5.0 {
        // sound is not long enough
      }
      
      let startTime = CMTime(value: 0, timescale: 1)
      let stopTime = CMTime(value: 5, timescale: 1)
      exporter.timeRange = CMTimeRange(start: startTime, duration: stopTime)
      
      exporter.exportAsynchronously {
        print("export complete \(exporter.status)")
        switch exporter.status {
        case .cancelled:
          print("cancelled")
        case .failed:
          print("failed \(exporter.error?.localizedDescription ?? "")")
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
      
    } else {
      print("cannot create AVAssetExportSession for asset \(asset)")
    }
    
  }
  
  
  func exportUsingComposition() {
    guard let url = URL(string: mp3AudioFile) else {
      return
    }
    let assetItem = AVPlayerItem(url: url)
    
    let composition = AVMutableComposition()
    let compositionAudioTrack = composition.addMutableTrack(withMediaType: .audio, preferredTrackID: CMPersistentTrackID(kCMPersistentTrackID_Invalid))
    let sourceAudioTrack = assetItem.asset.tracks(withMediaType: AVMediaType.audio).first!
    
    do {
      try compositionAudioTrack?.insertTimeRange(CMTimeRange(start: CMTime.zero, duration: assetItem.duration), of: sourceAudioTrack, at: CMTime.zero)
    } catch {
      print("failed exportUsingComposition: \(error)")
    }
    
    let compatiblePresets = AVAssetExportSession.exportPresets(compatibleWith: composition)
    var preset: String = AVAssetExportPresetPassthrough
    if compatiblePresets.contains(AVAssetExportPresetAppleM4A) {
      preset = AVAssetExportPreset1920x1080 // can change preset here - see doc for more presets
      //preset = AVAssetExportPresetAppleM4A // does not work
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
