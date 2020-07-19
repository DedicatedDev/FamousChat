//
//  MainVideoCallingVC.swift
//  famouschat
//
//  Created by angel oni on 2019/2/6.
//  Copyright © 2019 Oni Angel. All rights reserved.
//

import UIKit
import AudioToolbox
import AVFoundation


class MainVideoCallingVC: UIViewController {
    
    var player: AVAudioPlayer?
    
    @IBOutlet weak var photo: UIImageView!
    @IBOutlet weak var name: UILabel!
    
    
    // var isCallMadeByMe:Bool = false
    
    var timer: Timer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.isNavigationBarHidden = true
        
        photo.load(url: ShareData.selected_book.profile.photo!)
        name.text = ShareData.selected_book.profile.name!
        timer = Timer.scheduledTimer(timeInterval: 1.2, target: self, selector: #selector(fire), userInfo: nil, repeats: true)
        playSound()
        
        setCallBacks()
    }
    
    func playSound() {
        
        
        guard let url = Bundle.main.url(forResource: "internal_ring", withExtension: "mp3") else { return }
        
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
            try AVAudioSession.sharedInstance().setActive(true)
            
            
            
            /* The following line is required for the player to work on iOS 11. Change the file type accordingly*/
            player = try AVAudioPlayer(contentsOf: url, fileTypeHint: AVFileType.mp3.rawValue)
            
            /* iOS 10 and earlier require the following line:
             player = try AVAudioPlayer(contentsOf: url, fileTypeHint: AVFileTypeMPEGLayer3) */
            
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
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        DispatchQueue.main.async {
            if let time = self.timer {
                time.invalidate()
            }
            self.stopSound()
        }
    }
    
    @objc func fire()
    {
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
    }
    
    
    
    func setCallBacks()
    {
        QuickBloxHelper.sharedInstance.callDidAcceptByOpponent = {
            
            DispatchQueue.main.async {
                self.player?.stop()
                self.timer.invalidate()
            }
            
            CallTimmer.sharedInstance.startCallTime()
            UIApplication.shared.keyWindow?.setRootViewController(MainVideoChatVC(), options: UIWindow.TransitionOptions(direction: .toRight, style: .easeIn), slide_direction: .fromLeftToRight)
            
        }
        
        QuickBloxHelper.sharedInstance.callDidEndCallBack = {
            
            QuickBloxHelper.sharedInstance.lastCallTimeInterval = CallTimmer.sharedInstance.endCallTimer()
            DispatchQueue.main.async {
                self.player?.stop()
                self.timer.invalidate()
                
                
            }
            self.dismiss(animated: true, completion: nil)
            CommonFuncs().doneAlert(ShareData.appTitle, "\(ShareData.selected_book.profile.name!) rejected your call", "CLOSE", {self.navigationController?.popViewController(animated: true)})
        }
    }
    
    
    
    @IBAction func cancelAction(_ sender: Any) {
        
        QuickBloxHelper.sharedInstance.rejectCall()
        self.dismiss(animated: true, completion: nil)
        
        DispatchQueue.main.async {
            self.player?.stop()
            self.timer.invalidate()
            self.navigationController?.popViewController(animated: true)
            
        }
        
    }
    
}
