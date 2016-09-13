//: ## Analyze sound
//: More exercises from Andy Farnell's "Designing Sound"

import XCPlayground
import AudioKit

//
let tape = try AKAudioFile(readFileName: "timerbell.mp3")
tape.sampleRate

let player = try AKAudioPlayer(file: tape) {
    print("completion callBack has been triggered !")
}

AudioKit.output = player
AudioKit.start()
player.looping = true

class PlaygroundView: AKPlaygroundView {
    
    override func setup() {
        
        addTitle("Audio Player")
        
        addSubview(AKResourcesAudioFileLoaderView(
            player: player,
            filenames: ["timerbell.mp3"]))
    }
    

}


XCPlaygroundPage.currentPage.needsIndefiniteExecution = true
XCPlaygroundPage.currentPage.liveView = PlaygroundView()