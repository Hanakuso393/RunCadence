//
//  MetronomeViewModel.swift
//  RunningApp
//
//  Created by Ryan S on 4/12/25.
//

import Foundation
import Observation
import AVFoundation

@Observable
class MetronomeViewModel {
    var bpm: Double = 120 {
        didSet {
            if isRunning {
                restartTimer()
            }
        }
    }
    var isRunning = false

    private var timer: Timer?

    // AVAudioEngine components
    private let engine = AVAudioEngine()
    private let playerNode = AVAudioPlayerNode()
    private var audioBuffer: AVAudioPCMBuffer?

    init() {
        setupAudioEngine()
    }

    func toggleMetronome() {
        isRunning.toggle()
        isRunning ? start() : stop()
    }

    private func start() {
        guard audioBuffer != nil else {
            print("Audio buffer is nil")
            return
        }

        if !engine.isRunning {
            do {
                try engine.start()
            } catch {
                print("Failed to start audio engine: \(error)")
                return
            }
        }

        playerNode.play()
        startTimer()
    }

    private func stop() {
        timer?.invalidate()
        timer = nil
        playerNode.stop()
    }
    
    private func restartTimer() {
        timer?.invalidate()
        startTimer()
    }
    
    private func startTimer() {
        let interval = 60.0 / bpm
        timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { [weak self] _ in
            self?.playClick()
        }
    }

    private func playClick() {
        guard let buffer = audioBuffer else { return }
        playerNode.scheduleBuffer(buffer, at: nil, options: .interrupts, completionHandler: nil)
    }

    private func setupAudioEngine() {
        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.playback, mode: .default, options: [.mixWithOthers])
            try session.setActive(true)
        } catch {
            print("Failed to configure audio session: \(error)")
        }

        guard let url = Bundle.main.url(forResource: "click", withExtension: "wav") else {
            print("Click sound not found")
            return
        }

        do {
            let file = try AVAudioFile(forReading: url)
            let format = file.processingFormat
            let frameCount = AVAudioFrameCount(file.length)

            audioBuffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: frameCount)
            try file.read(into: audioBuffer!)

            engine.attach(playerNode)
            engine.connect(playerNode, to: engine.mainMixerNode, format: format)
            try engine.start()
        } catch {
            print("Failed to set up AVAudioEngine: \(error)")
        }
    }
}
