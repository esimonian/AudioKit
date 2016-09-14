//: ## Analyze sound
//: More exercises from Andy Farnell's "Designing Sound"

import XCPlayground
import AudioKit

//
let tape = try AKAudioFile(readFileName: "timerbell.mp3")
tape.sampleRate
tape.samplesCount
let player = try AKAudioPlayer(file: tape) {
    print("completion callBack has been triggered !")
}

var mixer = AKMixer(player)
var tracker = AKFrequencyTracker(mixer)
AudioKit.output = mixer
AudioKit.start()

class PlaygroundView: AKPlaygroundView {
    
    override func setup() {
        
        addTitle("Analyze Sound")
        
        addSubview(AKResourcesAudioFileLoaderView(
            player: player,
            filenames: ["timerbell.mp3"]))
        
        let plot = AKNodeFFTPlot(mixer, frame: CGRect(x: 0, y: 0, width: 500, height: 500))
        plot.shouldFill = true
        plot.shouldMirror = false
        plot.shouldCenterYAxis = false
        plot.color = AKColor.purpleColor()
        
        addSubview(plot)
        
        let plot2 = AKNodeOutputPlot(tracker, frame: CGRect.init(x: 0, y: 0, width: 440, height: 300))
        plot2.plotType = .Rolling
        plot2.shouldFill = true
        plot2.shouldMirror = true
        plot2.color = AKColor.redColor()
        
        addSubview(plot2)

    }
    

}


XCPlaygroundPage.currentPage.needsIndefiniteExecution = true
XCPlaygroundPage.currentPage.liveView = PlaygroundView()
