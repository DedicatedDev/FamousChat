//
//  StartWelcomeVC.swift
//  famouschat
//
//  Created by T-Tech Solutions LLC on 05/11/2018.
//  Copyright © 2018 T-Tech Solutions LLC. All rights reserved.
//

import UIKit

class StartWelcomeVC: UIViewController {

    @IBOutlet weak var next_frame: UIView!
    @IBOutlet weak var next_btn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        init_UI()
    }

    func init_UI()
    {
        let image = UIImage(named: "return")?.withRenderingMode(.alwaysTemplate)
        
        next_frame.layer.cornerRadius = next_frame.frame.width / 2
        next_frame.clipsToBounds = true
        next_frame.dropShadow(color: .lightGray, opacity: 0.8, offSet: CGSize.zero, radius: 5, scale: true)
        next_btn.setImage(image, for: .normal)
        next_btn.transform = next_btn.transform.rotated(by: CGFloat(Double.pi))
        next_btn.tintColor = UIColor.white
        
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(self.respondToSwipeGesture))
        swipeLeft.direction = UISwipeGestureRecognizerDirection.left
        self.view.addGestureRecognizer(swipeLeft)
    }
    
    @IBAction func nextAction(_ sender: Any) {
        
        self.navigationController?.pushViewController(StartSelectVC(), animated: true)
    }

}

extension StartWelcomeVC
{
    @objc func respondToSwipeGesture(gesture: UIGestureRecognizer)
    {
       
        
        if let swipeGesture = gesture as? UISwipeGestureRecognizer
        {
            switch swipeGesture.direction
            {
            
            case UISwipeGestureRecognizerDirection.left:
                
               self.navigationController?.pushViewController(StartSelectVC(), animated: true)
                
            default:
                break
            }
        }
    }
}
