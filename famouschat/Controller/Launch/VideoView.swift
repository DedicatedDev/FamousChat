//
//  VideoView.swift
//  koreanlive
//
//  Created by angel oni on 2019/4/13.
//  Copyright © 2019 oni. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation

class VideoView: UIView {
    
    var playerLayer: AVPlayerLayer?
    var player: AVPlayer?
    var isLoop: Bool = false
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.frame = UIScreen.main.bounds
        
    }
    
    func configure(url: String, local_or_sever: Bool) {
        
        var videoUrl: URL!
        if local_or_sever
        {
            videoUrl = URL(fileURLWithPath: Bundle.main.path(forResource: url, ofType: "png")!)
        }
        else
        {
            videoUrl = URL(fileURLWithPath: "\(ShareData.main_url)\(url)")
        }
        
        player = AVPlayer(url: videoUrl)
        playerLayer = AVPlayerLayer(player: player)
        playerLayer?.frame = bounds
        playerLayer?.videoGravity = AVLayerVideoGravity.resize
        if let playerLayer = self.playerLayer {
            layer.addSublayer(playerLayer)
        }
        NotificationCenter.default.addObserver(self, selector: #selector(reachTheEndOfTheVideo(_:)), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: self.player?.currentItem)
    }
    
    func play() {
        if player?.timeControlStatus != AVPlayer.TimeControlStatus.playing {
            player?.play()
        }
    }
    
    func pause() {
        player?.pause()
    }
    
    func stop() {
        player?.pause()
        player?.seek(to: kCMTimeZero)
    }
    
    @objc func reachTheEndOfTheVideo(_ notification: Notification) {
        if isLoop {
            player?.pause()
            player?.seek(to: kCMTimeZero)
            player?.play()
        }
    }
}
