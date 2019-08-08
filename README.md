# AudioTimeline
Timeline object designed to be used along with AVAudioEngine that enables current time tracking as well as continued time updates.
It makes it easy to build a custom audio player using AVAudioEngine.

###Features
- Keep track of the current time position of the audio being played
- Notify time updates via `TimelineDelegate`.
- Configure time updates rate using `timeUpdateRate` property in `TimelineDelegate`
- Track audio nodes current time via `playbackTime` property (useful when playing audio at a specific time is required)

###Notes
A useful usecase for this Timeline object is a custom audio player that plays different audio files synchronized. In order to do that the Timeline object keeps track of the current time for the nodes and provides a property to use it

#####Usage

```swift
guard let playbackTime = timeline.playbackTime else { return }
let time1 = AVAudioTime(sampleTime: AVAudioFramePosition(playbackTime * audio1SampleRate), atRate: audio1SampleRate)
let time2 = AVAudioTime(sampleTime: AVAudioFramePosition(playbackTime * audio2SampleRate), atRate: audio2SampleRate)
playerNode1.play(at: time1)
playerNode2.play(at: time2)
```
*Players nodes must be attached to AVAudioEngine's mainMixerNode*
