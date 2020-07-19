//
//  MainVideoReceiveVC.swift
//  famouschat
//
//  Created by T-Tech Solutions LLC on 28/11/2018.
//  Copyright © 2018 T-Tech Solutions LLC. All rights reserved.
//

import UIKit
import AudioToolbox
import AVFoundation

class MainVideoReceiveVC: UIViewController {
    
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var oponentImage: UIImageView!
    @IBOutlet weak var accept_btn: UIButton!
    @IBOutlet weak var reject_btn: UIButton!
    
    var player: AVAudioPlayer?
    
    var timer: Timer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.isNavigationBarHidden = true
        
        timer = Timer.scheduledTimer(timeInterval: 4.0, target: self, selector: #selector(fire), userInfo: nil, repeats: true)
        self.playSoundCallerRing()
        
        oponentImage.load(url: ShareData.selected_book.profile.photo!)
        lblName.text = ShareData.selected_book.profile.name!
        
        setCallBacks()
        
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        DispatchQueue.main.async {
            if let time = self.timer {
                time.invalidate()
            }
            self.stopSound()
        }
    }
    
}


extension MainVideoReceiveVC
{
    
    @objc func fire()
    {
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
    }
    
    func playSoundCallerRing() {
        
        
        guard let url = Bundle.main.url(forResource: "caller_ring", withExtension: "mp3") else { return }
        
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
            try AVAudioSession.sharedInstance().setActive(true)
            
            player = try AVAudioPlayer(contentsOf: url, fileTypeHint: AVFileType.mp3.rawValue)
            
            guard let player = player else { return }
            player.numberOfLoops = 100
            player.play()
            
        } catch let error {
            print(error.localizedDescription)
        }
    }
    
    func stopSound(){
        
        guard let player = player else { return }
        player.stop()
    }
    
    func setCallBacks()
    {
        QuickBloxHelper.sharedInstance.callDidAcceptByOpponent = {
            
            DispatchQueue.main.async {
                self.player?.stop()
                self.timer.invalidate()
            }
            CallTimmer.sharedInstance.startCallTime()
            self.navigationController?.pushViewController(MainVideoChatVC(), animated: true)
        }
        
        QuickBloxHelper.sharedInstance.callDidEndCallBack = {
            QuickBloxHelper.sharedInstance.lastCallTimeInterval = CallTimmer.sharedInstance.endCallTimer()
            DispatchQueue.main.async {
                self.player?.stop()
                self.timer.invalidate()
            }
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    
    @IBAction func tapToRejectCall(_ sender: UIButton) {
        
        QuickBloxHelper.sharedInstance.rejectCall()
        
        DispatchQueue.main.async {
            self.player?.stop()
            self.timer.invalidate()
        }
        
        self.dismiss(animated: true, completion: nil)
    }
    
    
    @IBAction func tapToAcceptCall(_ sender: UIButton) {
        
        QuickBloxHelper.sharedInstance.acceptCall()
        CallTimmer.sharedInstance.startCallTime()
        
    }
    
}
