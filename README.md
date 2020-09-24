# Audio-Trimming

## Play Audio 

Sample audio `https://dl.espressif.com/dl/audio/ff-16b-2c-44100hz.m4a`

```swift
func playAudio(with url: URL) {
  do {
    let data = try Data(contentsOf: url)
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
  
  print(trimmedFileURL)
  
  if FileManager.default.fileExists(atPath: trimmedFileURL.path) {
    print("file exists")
    try? FileManager.default.removeItem(at: trimmedFileURL)
  } else {
    print("file does not exist")
  }
  
  exportSession.outputURL = trimmedFileURL
  exportSession.outputFileType = .mp4
  
  let startTime = CMTime(value: 0, timescale: 1)
  let stopTime = CMTime(value: 3, timescale: 1)
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
      self.playAudio(with: trimmedFileURL)
    case .waiting:
      print("waiting")
    case .unknown:
      print("unknown")
    default:
      print("future case")
    }
  }
}
```

## Play Trimmed Audio from Documents Directory 

```swift 
func playFileFromDocumentsDirectory() {
  let docDir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
  let fileURL = docDir.appendingPathComponent(filename)
  playAudio(with: fileURL)
}
```


## Resources 

1. [Audio Samples](https://docs.espressif.com/projects/esp-adf/en/latest/design-guide/audio-samples.html)
2. [Trimming Audio Files](http://www.rockhoppertech.com/blog/ios-trimming-audio-files/) 
3. [Using AVMutableComposition to export an Audio file](https://www.nuomiphp.com/eplan/en/11860.html)
