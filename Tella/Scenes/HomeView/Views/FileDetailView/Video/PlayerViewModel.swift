//
//  Copyright © 2022 HORIZONTAL. All rights reserved.
//


import AVFoundation
import Combine

final class PlayerViewModel: ObservableObject {
    
    let player = AVPlayer()
    
    @Published var isPlaying = false
    @Published var shouldSeekVideo = false
    @Published var currentPosition: Double = .zero
    @Published var videoDuration: Double?
    @Published var shouldDisableRewind = false
    @Published var shouldDisableFastForward = false
    @Published var videoSize: CGSize?
    @Published var currentFile: VaultFileDB?
    @Published var videoIsReady = false

    private var cancellable: Set<AnyCancellable> = []
    private var timeObserver: Any?
    
    var appModel: MainAppModel
    var rootFile: VaultFileDB?
    var playList : [VaultFileDB?] = [] {
        didSet {
            guard let item = playList[currentItemIndex]  else {return}
            self.setCurrentItem(item)
        }
    }
    
    var currentItemIndex : Int = 0
    
    var isSeekInProgress = false {
        didSet {
            self.player.pause()
        }
    }
    
    var formattedCurrentPosition : String {
        return self.currentPosition.timeString()
    }
    
    var formattedVideoDuration : String {
        return self.videoDuration?.timeString() ?? ""
    }
    
    deinit {
        if let timeObserver = timeObserver {
            player.removeTimeObserver(timeObserver)
        }
    }
    init(appModel: MainAppModel, currentFile: VaultFileDB?, playList: [VaultFileDB?], rootFile: VaultFileDB?) {
        
        self.appModel = appModel
        self.currentFile = currentFile
        self.playList = playList
        self.rootFile = rootFile
        
        if let index = playList.firstIndex(of: currentFile) {
             currentItemIndex = index
        }

        if playList.count >= currentItemIndex + 1, let item = playList[currentItemIndex]   {
            self.setCurrentItem(item)
        }

        
        $shouldSeekVideo
            .dropFirst()
            .filter({ $0 == false })
            .sink(receiveValue: { [weak self] _ in
                guard let self = self else { return }
                
                let targetTime = CMTime(seconds: self.currentPosition ,
                                        preferredTimescale: 600)
                self.player.seek(to: targetTime) { _ in
                    self.isSeekInProgress = false
                    self.player.play()
                    
                }
            })
            .store(in: &cancellable)
        
        player.publisher(for: \.timeControlStatus)
            .sink { [weak self] status in
                switch status {
                case .playing:
                    self?.isPlaying = true
                case .paused:
                    self?.isPlaying = false
                case .waitingToPlayAtSpecifiedRate:
                    break
                @unknown default:
                    break
                }
            }
            .store(in: &cancellable)
        
        timeObserver = player.addPeriodicTimeObserver(forInterval: CMTime(seconds: 0.5, preferredTimescale: 600), queue: nil) { [weak self] time in
            guard let self = self else { return }
            if self.isSeekInProgress == false {
                
                self.currentPosition = time.seconds
                
                guard let duration = self.videoDuration else {
                    return
                }
                
                self.shouldDisableRewind = self.currentPosition == 0 ? true : false
                self.shouldDisableFastForward = self.currentPosition == duration ? true : false
            }
        }
    }
    
    func setCurrentItem(_ file: VaultFileDB?) {
        
        videoIsReady = false
        self.currentPosition = .zero
        self.videoDuration = nil
        self.player.pause()
        self.player.replaceCurrentItem(with: nil)
        
        guard let file = file else { return }
        
        DispatchQueue.main.async {
            guard let videoURL = self.appModel.vaultManager.loadVaultFileToURL(file: file)  else {return}
            let playerItem = AVPlayerItem(url:videoURL)
            self.player.replaceCurrentItem(with: playerItem)
            self.player.play()

            playerItem.publisher(for: \.status)
                .filter({ $0 == .readyToPlay })
                .sink(receiveValue: { [weak self] _ in
                    self?.videoIsReady = true
                    self?.videoDuration = playerItem.asset.duration.seconds
                })
                .store(in: &self.cancellable)

        }
    }
    
    func playVideo()  {
        
        if self.videoDuration == self.currentPosition {
            seekVideo(to: 0.0)
        } else {
            self.player.play()
        }
    }

    func showNextVideo() {
        if playList.count - 1 > currentItemIndex {
            deleteTmpFile()
            self.currentItemIndex += 1
            self.setCurrentItem(playList[self.currentItemIndex])
            self.currentFile = playList[self.currentItemIndex]
            
        }
    }
    
    func showPreviousVideo() {
        if currentItemIndex > 0 {
            deleteTmpFile()
            self.currentItemIndex -= 1
            self.setCurrentItem(playList[self.currentItemIndex])
            self.currentFile = playList[self.currentItemIndex]
        }
    }
    
    func rewind() {
        seekVideo(to: self.currentPosition - 10)
    }
    
    func fastForward() {
        seekVideo(to: self.currentPosition + 10)
    }
    
    private func seekVideo(to position: Double) {
        
        self.isSeekInProgress = true
        self.currentPosition = position
        
        let targetTime = CMTime(seconds: self.currentPosition ,
                                preferredTimescale: 600)
        self.player.seek(to: targetTime) { _ in
            self.isSeekInProgress = false
            self.player.play()
        }
    }
    
    func deleteTmpFile() {
        guard let url = self.player.currentItem?.url else {return}
        appModel.vaultManager.deleteFiles(files: [url])
    }
}


extension AVPlayerItem {
    var url: URL? {
        return (asset as? AVURLAsset)?.url
    }
}
