//
//  Timer.swift
//
//  Created by Pablo Balduz on 06/08/2019.
//  Copyright © 2019 Pablo Balduz. All rights reserved.
//

import Foundation

typealias NanoSeconds = UInt64
typealias TimeUpdater = Foundation.Timer

extension NanoSeconds {
    
    /// A `Double` representing the milliseconds for the given nanoseconds
    var milliseconds: Double {
        return Double(self) / 1_000_000
    }
    
    /// A `Double` representing the seconds for the given nanoseconds
    var seconds: Double {
        return Double(self) / 1_000_000_000
    }
}

/// The `TimerDelegate` provides an interface for responding to `Timer` instance events. This includes whenever a time update happens.
protocol TimerDelegate: class {
    
    /// Triggered when a time update happens according to `TimerUpdateRate` value in `Timer`
    ///
    /// - Parameters:
    ///   - time: The time elapsed (expressed in nanoseconds) since the last time the `Timer` instance was started
    func timeDidUpdate(timeElapsedSinceLastStart time: NanoSeconds)
}


/// The `Timer` class is a custom timer that provides the elapsed time between a start and a stop. This time is expressed in nanoseconds. It also triggers time updates notifications via a `TimerDelegate`.
class Timer {
    
    // MARK: - Public properties
    
    /// A `TimeInterval` to control the time updates triggering rate
    static var TimerUpdateRate: TimeInterval = 0.1
    
    /// A `TimerDelegate` to handle events from `Timer`
    weak var delegate: TimerDelegate?
    
    /// A `UInt64` value representing the time elapsed since the `Timer` instance was started. It is expressed in nanoseconds
    var currentElapsed: NanoSeconds {
        let elapsed = stopTime ?? mach_absolute_time() - startTime
        return elapsed * NanoSeconds(Timer.b.numer) / NanoSeconds(Timer.b.denom)
    }
    
    // MARK: - Private properties
    
    private static var b: mach_timebase_info = mach_timebase_info(numer: 0, denom: 0)
    private var startTime: NanoSeconds = 0
    private var stopTime: NanoSeconds?
    
    private var updater: TimeUpdater?
    
    // MARK: - Init
    
    /// Initializes `Timer` instance
    init() {
        mach_timebase_info(&Timer.b)
    }
    
    // MARK: - Private methods
    
    @objc private func timerUpdate(timer: TimeUpdater) {
        self.delegate?.timeDidUpdate(timeElapsedSinceLastStart: self.currentElapsed)
    }
    
    // MARK: - Public methods
    
    /// Starts counting and initializes time updates if a `TimerDelegate` is set
    func start() {
        stopTime = nil
        startTime = mach_absolute_time()
        if delegate != nil && updater == nil {
            let timer = TimeUpdater(timeInterval: Timer.TimerUpdateRate, repeats: true, block: timerUpdate)
            RunLoop.current.add(timer, forMode: .common)
            updater = timer
        }
    }
    
    /// Stops counting and time updates
    func stop() {
        stopTime = mach_absolute_time()
        updater?.invalidate()
        updater = nil
    }
}
