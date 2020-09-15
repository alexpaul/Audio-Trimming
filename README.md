# Audio-Trimming

## Play Audio 

Sample audio `https://dl.espressif.com/dl/audio/ff-16b-2c-44100hz.m4a`

```swift
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
```

## Play Audio from the Bundle

```swift 
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
```

## Trim and Save Audio to Documents Directory

```swift 
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
```


## Resources 

1. [Audio Samples](https://docs.espressif.com/projects/esp-adf/en/latest/design-guide/audio-samples.html)
2. [Trimming Audio Files](http://www.rockhoppertech.com/blog/ios-trimming-audio-files/) 
3. [Using AVMutableComposition to export an Audio file](https://www.nuomiphp.com/eplan/en/11860.html)
