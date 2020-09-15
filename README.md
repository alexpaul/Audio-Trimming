# Audio-Trimming

## Play Audio 

Sample audio `https://dl.espressif.com/dl/audio/ff-16b-2c-44100hz.m4a`

```swift
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
```


## Save Audio 

## Trim Audio 


## Resources 

1. [Audio Samples](https://docs.espressif.com/projects/esp-adf/en/latest/design-guide/audio-samples.html)
