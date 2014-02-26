# TMAERecorder

This is a drop-in replacement of AVAudioRecorder, implemented using [The Amazing Audio Engine](http://theamazingaudioengine.com).

It allows you to use an audio filter during recording, processing in real time the recorded sound before saving it. You can use it to implement filters like the pitch shifting filter used in the [Tuenti iOS app.](https://itunes.apple.com/es/artist/tuenti-technologies-sl/id349705798)

A sample app and a simple reverb filter are included as reference.

## Installing

### Using CocoaPods

1. Include the following line in your `Podfile`:
   ```
   pod 'TMAERecorder', :git => 'https://github.com/tuenti/TMAERecorder'
   ```
2. Run `pod install`

### Manually

1. Clone, add as a submodule or [download](https://github.com/tuenti/TMAERecorder/zipball/master) TMAERecorder.
2. Add all the files under `Classes` to your project.
3. Make sure your project is configured to use ARC.

## Dependencies of the sample app

The sample app uses [Typhoon](http://www.typhoonframework.org) as dependency injection container and [The Amazing Audio Engine](http://theamazingaudioengine.com) to ease audio recording and filtering. Both dependencies are managed using [CocoaPods](http://cocoapods.org). Once you have cloned this repository, and with CocoaPods set up, please install these dependencies opening a Terminal window, changing to the Xcode project directory and running
   ```
   $ pod install
   ```
   
Make sure to always open the Xcode workspace instead of the project file when building the sample app:
   ```
   $ open TMAERecorder sample.xcworkspace
   ```

## Credits & Contact

TMAERecorder was created by [iOS team at Tuenti Technologies S.L.](http://github.com/tuenti).
You can follow Tuenti engineering team on Twitter [@tuentieng](http://twitter.com/tuentieng).

## License

TMAERecorder is available under the Apache License, Version 2.0. See LICENSE file for more info.
