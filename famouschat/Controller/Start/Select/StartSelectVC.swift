//
//  StartSelectVC.swift
//  famouschat
//
//  Created by T-Tech Solutions LLC on 05/11/2018.
//  Copyright © 2018 T-Tech Solutions LLC. All rights reserved.
//

import UIKit

class StartSelectVC: UIViewController {

    @IBOutlet weak var sign_btn: UIButton!
    @IBOutlet weak var no_btn: UIButton!

    
    override func viewDidLoad() {
        super.viewDidLoad()

        init_UI()
    }

    func init_UI()
    {
        
        sign_btn.layer.cornerRadius = CGFloat(ShareData.btn_radius)
        sign_btn.clipsToBounds = true
        sign_btn.dropShadow(color: .white, opacity: 0.8, offSet: CGSize.zero, radius: 3, scale: true)
        
        no_btn.layer.cornerRadius = CGFloat(ShareData.btn_radius)
        no_btn.clipsToBounds = true
        no_btn.dropShadow(color: .white, opacity: 0.8, offSet: CGSize.zero, radius: 3, scale: true)
        
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(self.respondToSwipeGesture))
        swipeRight.direction = UISwipeGestureRecognizerDirection.right
        self.view.addGestureRecognizer(swipeRight)
    }
    
    @IBAction func signAction(_ sender: Any) {
        
        ShareData.user_or_influencer = false
        self.navigationController?.pushViewController(StartCategoryVC(), animated: true)
        
    }
    
    @IBAction func noAction(_ sender: Any) {
        
        ShareData.user_or_influencer = true
        self.navigationController?.pushViewController(StartCategoryVC(), animated: true)
        
    }
}

extension StartSelectVC
{
    @objc func respondToSwipeGesture(gesture: UIGestureRecognizer)
    {
        if let swipeGesture = gesture as? UISwipeGestureRecognizer
        {
            switch swipeGesture.direction
            {
                
            case UISwipeGestureRecognizerDirection.right:
                
                self.navigationController?.popViewController(animated: true)
                
            default:
                break
            }
        }
    }
}
