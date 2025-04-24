//
//  Copyright © 2022 HORIZONTAL. All rights reserved.
//

import Foundation
import AVFoundation


class QueuePlayer: NSObject, ObservableObject {

    var queuePlayer: AVQueuePlayer?

    func playAudio(playerItems: [AVPlayerItem])  {
        self.queuePlayer = AVQueuePlayer(items: playerItems)
        self.queuePlayer?.actionAtItemEnd = .advance
        
        self.queuePlayer?.play()

    }
    func pauseAudio() {
        self.queuePlayer?.pause()
    }
}
