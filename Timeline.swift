//
//  Timeline.swift
//
//  Created by Pablo Balduz on 06/08/2019.
//  Copyright © 2019 Pablo Balduz. All rights reserved.
//

import AVFoundation

/// The `TimelineDelegate` provides an interface to respond to `Timeline` events as well as to configure it.
protocol TimelineDelegate: class {
    
    /// A `TimeInterval` to control the time updates triggering rate
    var timeUpdateRate: TimeInterval { get }
    
    /// Triggered when a time update happens according to `timeUpdateRate` property value
    ///
    /// - Parameters:
    ///   - time: The time elapsed (expressed in seconds) since the `Timeline` instance was started
    func currentTimeDidUpdate(time: Double)
}

extension TimelineDelegate {
    var timeUpdateRate: TimeInterval { return 0.1 }
}

/// Custom timeline designed to work along with an `AVAudioEngine` while playing audio files.
/// It provides the ability to track the current position of the audio expressed in seconds.
/// It also provides a `TimelineDelegate` that enables responding to time updates.
class Timeline {
    
    // MARK: - Public properties
    
    /// A `Double` representing the current second in the timeline
    var currentTime: Double {
        return lastPauseTime + currentElapsedTime
    }
    
    /**
     A `Double` representing the engine last render time expressed in seconds
     
     This is useful for resuming audio at a specific time when working with different players and a synchronized start is required
 
     ## Usage example: ##
     ````
     guard let playbackTime = timeline.playbackTime else { return }
     let time = AVAudioTime(sampleTime: AVAudioFramePosition(playbackTime * audioSampleRate), atRate: audioSampleRate)
     playerNode.play(at: time)
     ````
    */
    var playbackTime: Double? {
        guard let time = engine.mainMixerNode.lastRenderTime else { return nil }
        return Double(time.sampleTime) / time.sampleRate
    }
    
    /// A `Bool` indicating whether the timeline is active or not
    var isRunning: Bool {
        return running
    }
    
    /// A `TimelineDelegate` to handle events and configure the timeline
    weak var delegate: TimelineDelegate? {
        didSet {
            guard let delegate = delegate else { return }
            Timer.TimerUpdateRate = delegate.timeUpdateRate
        }
    }
    
    // MARK: - Private properties
    
    private var currentElapsedTime: Double = 0
    private var lastPauseTime: Double = 0
    private var timer = Timer()
    private var running: Bool = false
    unowned private let engine: AVAudioEngine
    
    // MARK: - Public properties
    
    /// Initializes a new `Timeline` object with the specified `AVAudioEngine`
    ///
    /// - Parameters:
    ///   - engine: The `AVAudioEngine` used to keep track of the time
    /// - Returns:
    ///   An initialized `Timeline` instance with the specified `AVAudioEngine`
    init(engine: AVAudioEngine) {
        self.engine = engine
        timer.delegate = self
    }
    
    // MARK: - Public methods
    
    /// Starts the timeline from zero
    func start() {
        timer.start()
        running = true
    }
    
    /// Pauses the timeline
    ///
    /// This causes the stop of time updates being triggered
    func pause() {
        lastPauseTime += timer.currentElapsed.seconds
        timer.stop()
        running = false
    }
    
    /// Sets the current time to zero and stops the timeline
    ///
    /// This causes the stop of time updates being triggered
    func reset() {
        timer.stop()
        lastPauseTime = 0
        running = false
    }
    
    /// Seeks current time a specified amount of time specfied in seconds
    /// - Parameters:
    ///   - seconds: The number of seconds the timeline should add to current time
    ///
    /// A negative value will result in moving backwards in the timeline
    func seek(_ seconds: Double) {
        lastPauseTime += seconds
    }
}

extension Timeline: TimerDelegate {
    
    func timeDidUpdate(timeElapsedSinceLastStart time: NanoSeconds) {
        currentElapsedTime = time.seconds
        delegate?.currentTimeDidUpdate(time: lastPauseTime + time.seconds)
    }
}
