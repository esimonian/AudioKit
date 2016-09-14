//: ## Pedestrians
//: A British crossing signal implemented with AudioKit, an example from
//: Andy Farnell's excellent book "Designing Sound"
import XCPlayground
import AudioKit

let generator = AKOperationGenerator() { _ in
    
    // Generate a sine wave at the right frequency
    let crossingSignalTone = AKOperation.sineWave(frequency: 2500)
    
    // Periodically trigger an envelope around that signal
    let crossingSignalTrigger = AKOperation.periodicTrigger(period: 0.2)
    let crossingSignal = crossingSignalTone.triggeredWithEnvelope(
        trigger: crossingSignalTrigger,
        attack: 0.01,
        hold: 0.1,
        release: 0.01)
    
    // scale the volume
    return crossingSignal * 0.2
}

var mixer = AKMixer(generator)

let tracker = AKFrequencyTracker(mixer)

AudioKit.output = tracker
AudioKit.start()

//: Activate the signal
generator.start()
class PlaygroundView: AKPlaygroundView {
    
    var trackedAmplitudeSlider: AKPropertySlider?
    var trackedFrequencySlider: AKPropertySlider?
    var trackedRateSlider: AKPropertySlider?
    
    override func setup() {
        
        AKPlaygroundLoop(every: 0.1) {
            self.trackedAmplitudeSlider?.value = tracker.amplitude
            self.trackedFrequencySlider?.value = tracker.frequency
            
            
        }
        
        addTitle("Visualize Pedistrian Sound")
        
        trackedAmplitudeSlider = AKPropertySlider(
            property: "Tracked Amplitude",
            format: "%0.3f",
            value: 0, maximum: 0.55,
            color: AKColor.greenColor()
        ) { sliderValue in
            // Do nothing, just for display
        }
        addSubview(trackedAmplitudeSlider!)
        
        addSubview(AKPropertySlider(
            property: "Rate",
            format: "%0.3f",
            value: 0, maximum: 0.55,
            color: AKColor.greenColor()
        ) { sliderValue in
            
            })
        
        trackedFrequencySlider = AKPropertySlider(
            property: "Tracked Frequency",
            format: "%0.3f",
            value: 0, maximum: 1000,
            color: AKColor.redColor()
        ) { sliderValue in
            // Do nothing, just for display
        }
        addSubview(trackedFrequencySlider!)
        
        //amplitude
        addSubview(AKRollingOutputPlot.createView(width: 440, height: 300))
        
        //FFT
        let plot = AKNodeFFTPlot(mixer, frame: CGRect(x: 0, y: 0, width: 500, height: 300))
        plot.shouldFill = true
        plot.shouldMirror = false
        plot.shouldCenterYAxis = false
        plot.color = AKColor.redColor()
        
        addSubview(plot)
        
    }
}
XCPlaygroundPage.currentPage.needsIndefiniteExecution = true
XCPlaygroundPage.currentPage.liveView = PlaygroundView()

