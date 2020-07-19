//
//  Extension.swift
//  famouschat
//
//  Created by T-Tech Solutions LLC on 18/11/2018.
//  Copyright © 2018 T-Tech Solutions LLC. All rights reserved.
//

import Foundation
import UIKit
import ImageIO

extension UIViewController
{
    
    func initProgressDlg(_ color: UIColor) -> UIActivityIndicatorView
    {
        let progressDlg = UIActivityIndicatorView()
        progressDlg.center.x = UIScreen.main.bounds.width / 2
        progressDlg.center.y = UIScreen.main.bounds.height / 2
        progressDlg.hidesWhenStopped = true
        let transform = CGAffineTransform(scaleX: 2, y: 2)
        progressDlg.transform = transform
        progressDlg.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.white
        progressDlg.color = color
        view.addSubview(progressDlg)
        
        return progressDlg
    }
    
}

public extension UIWindow {
    
    public struct TransitionOptions {
        
        
        public enum Curve {
            case linear
            case easeIn
            case easeOut
            case easeInOut
            
            internal var function: CAMediaTimingFunction {
                let key: String!
                switch self {
                case .linear:        key = kCAMediaTimingFunctionLinear
                case .easeIn:        key = kCAMediaTimingFunctionEaseIn
                case .easeOut:        key = kCAMediaTimingFunctionEaseOut
                case .easeInOut:    key = kCAMediaTimingFunctionEaseInEaseOut
                }
                return CAMediaTimingFunction(name: key)
            }
        }
        
        
        public enum Direction {
            case fade
            case toTop
            case toBottom
            case toLeft
            case toRight
            
            /// Return the associated transition
            ///
            /// - Returns: transition
            internal func transition() -> CATransition {
                let transition = CATransition()
                transition.type = kCATransitionPush
                switch self {
                case .fade:
                    transition.type = kCATransitionFade
                    transition.subtype = nil
                case .toLeft:
                    transition.subtype = kCATransitionFromLeft
                case .toRight:
                    transition.subtype = kCATransitionFromRight
                case .toTop:
                    transition.subtype = kCATransitionFromTop
                case .toBottom:
                    transition.subtype = kCATransitionFromBottom
                }
                return transition
            }
        }
        
        
        public enum Background {
            case solidColor(_: UIColor)
            case customView(_: UIView)
        }
        
        
        public var duration: TimeInterval = 0.20
        
        
        public var direction: TransitionOptions.Direction = .toRight
        
        
        public var style: TransitionOptions.Curve = .easeInOut
        
        
        public var background: TransitionOptions.Background? = nil
        
        public init(direction: TransitionOptions.Direction = .toRight, style: TransitionOptions.Curve = .linear) {
            self.direction = direction
            self.style = style
        }
        
        public init() { }
        
        
        internal var animation: CATransition {
            let transition = self.direction.transition()
            transition.duration = self.duration
            transition.timingFunction = self.style.function
            return transition
        }
    }
    
    
    public func setRootViewController(_ controller: UIViewController, options: TransitionOptions = TransitionOptions(), slide_direction: NVSlideMenuControllerSlideDirection) -> UIViewController {
        
        var transitionWnd: UIWindow? = nil
        if let background = options.background {
            transitionWnd = UIWindow(frame: UIScreen.main.bounds)
            switch background {
            case .customView(let view):
                transitionWnd?.rootViewController = UIViewController.newController(withView: view, frame: transitionWnd!.bounds)
            case .solidColor(let color):
                transitionWnd?.backgroundColor = color
            }
            transitionWnd?.makeKeyAndVisible()
        }
        
        // Make animation
        self.layer.add(options.animation, forKey: kCATransition)
        
        let menuVC = MenuViewController()
        
        let menuNavigationController = UINavigationController.init(rootViewController: menuVC)
        let navigationController = UINavigationController.init(rootViewController: controller)
        navigationController.navigationBar.isTranslucent = false
        let slideMenuVC = NVSlideMenuController.init(menuViewController: menuNavigationController, andContentViewController: navigationController)
        slideMenuVC?.slideDirection = slide_direction
        
        self.rootViewController = slideMenuVC
        self.makeKeyAndVisible()
        
        if let wnd = transitionWnd {
            DispatchQueue.main.asyncAfter(deadline: (.now() + 1 + options.duration), execute: {
                wnd.removeFromSuperview()
            })
        }
        
        return controller
    }
}

internal extension UIViewController {
    
    
    static func newController(withView view: UIView, frame: CGRect) -> UIViewController {
        view.frame = frame
        let controller = UIViewController()
        controller.view = view
        return controller
    }
    
}




extension UIView {
    
    func dropShadow(color: UIColor, opacity: Float = 0.5, offSet: CGSize, radius: CGFloat = 1, scale: Bool = true) {
         
        layer.shadowColor = color.cgColor
        layer.shadowOpacity = opacity
        layer.shadowOffset = offSet
        layer.shadowRadius = radius
        layer.masksToBounds = false
        layer.rasterizationScale = scale ? UIScreen.main.scale : 1
    }
    
    func roundCorners(corners: UIRectCorner, radius: CGFloat) {
        
        let path = UIBezierPath(roundedRect: bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        layer.mask = mask
    }
    
    func addGrdient (mainColor :[CGColor]){
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = self.bounds
        gradientLayer.colors = mainColor
        
        self.layer.addSublayer(gradientLayer)
    }
        
}


extension UIImage {
    
    class func imageWithColor(color: UIColor, size: CGSize) -> UIImage {
        let rect: CGRect = CGRect(x:0, y:0, width:size.width, height:size.height)
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        color.setFill()
        UIRectFill(rect)
        let image: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return image
    }
    
    
}


extension UIImageView
{

    func load(url: String) {
        DispatchQueue.global().async { [weak self] in
            
            let imgURL:String = "\(ShareData.main_url)\(url)"
            
            self?.sd_setImage(with: URL(string: imgURL), placeholderImage: UIImage.init(named: "non_profile"))
            
        }
    }
    
    public func loadGif(name: String) {
        DispatchQueue.global().async {
            let image = UIImage.gif(name: name)
            DispatchQueue.main.async {
                self.image = image
            }
        }
    }
    
    @available(iOS 9.0, *)
    public func loadGif(asset: String) {
        DispatchQueue.global().async {
            let image = UIImage.gif(asset: asset)
            DispatchQueue.main.async {
                self.image = image
            }
        }
    }
    
}

extension UIImage {
    
    public class func gif(data: Data) -> UIImage? {
        // Create source from data
        guard let source = CGImageSourceCreateWithData(data as CFData, nil) else {
            print("SwiftGif: Source for the image does not exist")
            return nil
        }
        
        return UIImage.animatedImageWithSource(source)
    }
    
    public class func gif(url: String) -> UIImage? {
        // Validate URL
        guard let bundleURL = URL(string: url) else {
            print("SwiftGif: This image named \"\(url)\" does not exist")
            return nil
        }
        
        // Validate data
        guard let imageData = try? Data(contentsOf: bundleURL) else {
            print("SwiftGif: Cannot turn image named \"\(url)\" into NSData")
            return nil
        }
        
        return gif(data: imageData)
    }
    
    public class func gif(name: String) -> UIImage? {
        // Check for existance of gif
        guard let bundleURL = Bundle.main
            .url(forResource: name, withExtension: "gif") else {
                print("SwiftGif: This image named \"\(name)\" does not exist")
                return nil
        }
        
        // Validate data
        guard let imageData = try? Data(contentsOf: bundleURL) else {
            print("SwiftGif: Cannot turn image named \"\(name)\" into NSData")
            return nil
        }
        
        return gif(data: imageData)
    }
    
    @available(iOS 9.0, *)
    public class func gif(asset: String) -> UIImage? {
        // Create source from assets catalog
        guard let dataAsset = NSDataAsset(name: asset) else {
            print("SwiftGif: Cannot turn image named \"\(asset)\" into NSDataAsset")
            return nil
        }
        
        return gif(data: dataAsset.data)
    }
    
    internal class func delayForImageAtIndex(_ index: Int, source: CGImageSource!) -> Double {
        var delay = 0.1
        
        // Get dictionaries
        let cfProperties = CGImageSourceCopyPropertiesAtIndex(source, index, nil)
        let gifPropertiesPointer = UnsafeMutablePointer<UnsafeRawPointer?>.allocate(capacity: 0)
        defer {
            gifPropertiesPointer.deallocate()
        }
        if CFDictionaryGetValueIfPresent(cfProperties, Unmanaged.passUnretained(kCGImagePropertyGIFDictionary).toOpaque(), gifPropertiesPointer) == false {
            return delay
        }
        
        let gifProperties:CFDictionary = unsafeBitCast(gifPropertiesPointer.pointee, to: CFDictionary.self)
        
        // Get delay time
        var delayObject: AnyObject = unsafeBitCast(
            CFDictionaryGetValue(gifProperties,
                                 Unmanaged.passUnretained(kCGImagePropertyGIFUnclampedDelayTime).toOpaque()),
            to: AnyObject.self)
        if delayObject.doubleValue == 0 {
            delayObject = unsafeBitCast(CFDictionaryGetValue(gifProperties,
                                                             Unmanaged.passUnretained(kCGImagePropertyGIFDelayTime).toOpaque()), to: AnyObject.self)
        }
        
        if let delayObject = delayObject as? Double, delayObject > 0 {
            delay = delayObject
        } else {
            delay = 0.1 // Make sure they're not too fast
        }
        
        return delay
    }
    
    internal class func gcdForPair(_ a: Int?, _ b: Int?) -> Int {
        var a = a
        var b = b
        // Check if one of them is nil
        if b == nil || a == nil {
            if b != nil {
                return b!
            } else if a != nil {
                return a!
            } else {
                return 0
            }
        }
        
        // Swap for modulo
        if a! < b! {
            let c = a
            a = b
            b = c
        }
        
        // Get greatest common divisor
        var rest: Int
        while true {
            rest = a! % b!
            
            if rest == 0 {
                return b! // Found it
            } else {
                a = b
                b = rest
            }
        }
    }
    
    internal class func gcdForArray(_ array: Array<Int>) -> Int {
        if array.isEmpty {
            return 1
        }
        
        var gcd = array[0]
        
        for val in array {
            gcd = UIImage.gcdForPair(val, gcd)
        }
        
        return gcd
    }
    
    internal class func animatedImageWithSource(_ source: CGImageSource) -> UIImage? {
        let count = CGImageSourceGetCount(source)
        var images = [CGImage]()
        var delays = [Int]()
        
        // Fill arrays
        for i in 0..<count {
            // Add image
            if let image = CGImageSourceCreateImageAtIndex(source, i, nil) {
                images.append(image)
            }
            
            // At it's delay in cs
            let delaySeconds = UIImage.delayForImageAtIndex(Int(i),
                                                            source: source)
            delays.append(Int(delaySeconds * 1000.0)) // Seconds to ms
        }
        
        // Calculate full duration
        let duration: Int = {
            var sum = 0
            
            for val: Int in delays {
                sum += val
            }
            
            return sum
        }()
        
        // Get frames
        let gcd = gcdForArray(delays)
        var frames = [UIImage]()
        
        var frame: UIImage
        var frameCount: Int
        for i in 0..<count {
            frame = UIImage(cgImage: images[Int(i)])
            frameCount = Int(delays[Int(i)] / gcd)
            
            for _ in 0..<frameCount {
                frames.append(frame)
            }
        }
        
        // Heyhey
        let animation = UIImage.animatedImage(with: frames,
                                              duration: Double(duration) / 1000.0)
        
        return animation
    }
    
}



extension UIButton {
    
    func load(url: String) {
        DispatchQueue.global().async { [weak self] in
            
            let imgURL:String = "\(ShareData.main_url)\(url)"
            if let url = URL(string: imgURL)
            {  
                self?.sd_setImage(with: url, for: .normal, placeholderImage: UIImage.init(named: "non_profile"))
            }
            
        }
    }
    
    func shadow(color: UIColor, opacity: Float = 0.5, offSet: CGSize, radius: CGFloat = 1, scale: Bool = true) {
        
        layer.masksToBounds = false
        layer.shadowColor = color.cgColor
        layer.shadowOpacity = opacity
        layer.shadowOffset = offSet
        layer.shadowRadius = radius
        
        layer.shadowPath = UIBezierPath(rect: self.bounds).cgPath
        layer.shouldRasterize = true
        layer.rasterizationScale = scale ? UIScreen.main.scale : 1
    }
}


extension UITextField
{
    func colorPlaceHolder(_ str: String, _ color: UIColor)
    {
        self.attributedPlaceholder = NSAttributedString(string: str,
                                                         attributes: [NSAttributedStringKey.foregroundColor: color])
    }
}

extension String {
    
    func widthOfString(font: UIFont) -> CGFloat {
        let fontAttributes = [NSAttributedStringKey.font: font]
        let size = self.size(withAttributes: fontAttributes)
        return size.width
    }
    
    func heightOfString(font: UIFont) -> CGFloat {
        let fontAttributes = [NSAttributedStringKey.font: font]
        let size = self.size(withAttributes: fontAttributes)
        return size.height
    }
    
    func sizeOfString(font: UIFont) -> CGSize {
        let fontAttributes = [NSAttributedStringKey.font: font]
        return self.size(withAttributes: fontAttributes)
    }
}


extension UICollectionView {
    
    func scrollToLast() {
        
        guard numberOfSections > 0 else {
            return
        }
        
        let lastSection = numberOfSections - 1
        
        guard numberOfItems(inSection: lastSection) > 0 else {
            return
        }
        
        let lastItemIndexPath = IndexPath(item: numberOfItems(inSection: lastSection) - 1,
                                          section: lastSection)
        scrollToItem(at: lastItemIndexPath, at: .bottom, animated: true)
    }
    
    func scrollToFirst() {
        
        guard numberOfSections > 0 else {
            return
        }
        
        let lastSection = numberOfSections - 1
        
        guard numberOfItems(inSection: lastSection) > 0 else {
            return
        }
        
        let firstItemIndexPath = IndexPath(item: 0,
                                          section: lastSection)
        scrollToItem(at: firstItemIndexPath, at: .bottom, animated: true)
    }
    
    func scrollToIndex(index: Int) {
        
        guard numberOfSections > 0 else {
            return
        }
        
        let lastSection = numberOfSections - 1
        
        guard numberOfItems(inSection: lastSection) > 0 else {
            return
        }
        
        let firstItemIndexPath = IndexPath(item: index,
                                           section: lastSection)
        scrollToItem(at: firstItemIndexPath, at: .left, animated: true)
    }
    
    
    
}
