import Cocoa
import XCPlayground
import AudioKit

let mic = AKMicrophone()
let tape = try? AKAudioFile()
let player = try? AKAudioPlayer(file: tape!)
let recorder = try? AKNodeRecorder(node: mic, file: tape!)

AudioKit.output = player
AudioKit.start()

class ScreenView: NSView {
    override func addSubview(aView: NSView) {
        <#code#>
    }
    
}

let screenView: ScreenView = {
    $0.wantsLayer = true
    $0.layer?.backgroundColor = NSColor.whiteColor().CGColor
    return $0
}(ScreenView(frame: NSRect(x: 0, y: 0, width: 500, height: 1000)))

XCPlaygroundPage.currentPage.needsIndefiniteExecution = true
XCPlaygroundPage.currentPage.liveView = screenView