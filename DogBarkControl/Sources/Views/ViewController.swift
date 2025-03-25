import UIKit
import AVFoundation

class ViewController: UIViewController {
    
    private var audioEngine: AVAudioEngine?
    private var player: AVAudioPlayerNode?
    private var isPlaying = false
    
    private lazy var stopButton: UIButton = {
        let button = UIButton(configuration: .filled())
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Stop Dog Barking", for: .normal)
        button.configuration?.baseBackgroundColor = .systemRed
        button.configuration?.cornerStyle = .large
        button.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupAudio()
    }
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        view.addSubview(stopButton)
        
        NSLayoutConstraint.activate([
            stopButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stopButton.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            stopButton.widthAnchor.constraint(equalToConstant: 200),
            stopButton.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
    
    private func setupAudio() {
        audioEngine = AVAudioEngine()
        player = AVAudioPlayerNode()
        
        guard let audioEngine = audioEngine,
              let player = player else { return }
        
        let sampleRate = 44100.0
        let frequency = 20000.0 // 20kHz frequency
        let amplitude = 0.5
        
        let audioFormat = AVAudioFormat(standardFormatWithSampleRate: sampleRate, channels: 1)
        guard let audioFormat = audioFormat else { return }
        
        let buffer = createHighFrequencyBuffer(sampleRate: sampleRate,
                                             frequency: frequency,
                                             amplitude: amplitude,
                                             duration: 1.0)
        
        audioEngine.attach(player)
        audioEngine.connect(player, to: audioEngine.mainMixerNode, format: audioFormat)
        
        player.scheduleBuffer(buffer, at: nil, options: .loops)
        
        do {
            try audioEngine.start()
        } catch {
            print("Audio engine failed to start: \(error.localizedDescription)")
        }
    }
    
    private func createHighFrequencyBuffer(sampleRate: Double,
                                         frequency: Double,
                                         amplitude: Double,
                                         duration: Double) -> AVAudioPCMBuffer {
        let numberOfFrames = AVAudioFrameCount(sampleRate * duration)
        guard let buffer = AVAudioPCMBuffer(pcmFormat: AVAudioFormat(standardFormatWithSampleRate: sampleRate,
                                                                    channels: 1)!,
                                          frameCapacity: numberOfFrames) else {
            fatalError("Could not create buffer")
        }
        
        buffer.frameLength = numberOfFrames
        
        let data = buffer.floatChannelData?[0]
        let numberFrames = Int(numberOfFrames)
        
        for frame in 0..<numberFrames {
            let value = sin(2.0 * .pi * frequency * Double(frame) / sampleRate)
            data?[frame] = Float(value * amplitude)
        }
        
        return buffer
    }
    
    @objc private func buttonTapped() {
        guard let player = player else { return }
        
        if isPlaying {
            player.pause()
            stopButton.configuration?.baseBackgroundColor = .systemRed
            stopButton.setTitle("Stop Dog Barking", for: .normal)
        } else {
            player.play()
            stopButton.configuration?.baseBackgroundColor = .systemGreen
            stopButton.setTitle("Stop Sound", for: .normal)
        }
        
        isPlaying.toggle()
    }
}