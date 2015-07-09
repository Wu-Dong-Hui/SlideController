//
//  DTSlideController.swift
//  DTSlideController
//
//  Created by mmTravel on 15/7/9.
//  Copyright (c) 2015年 John Wu. All rights reserved.
//

import UIKit
import Foundation

private var associatedObjectKey = 0

class DTSlideController: UIViewController {
    enum SlideDirection: Int {
        case Home = 0
        case Left
        case Right
    }
    var backgroundImage: UIImage?
    let width: CGFloat = UIScreen.mainScreen().bounds.width
    let height: CGFloat = UIScreen.mainScreen().bounds.height
    
    private
    let FullDistance: CGFloat = 0.78
    let Proportion: CGFloat = 0.77
    
    var centerOfLeftViewAtBeginning: CGPoint!
    var proportionOfLeftView: CGFloat = 1
    var distanceOfLeftView: CGFloat = 50
    var distance: CGFloat = 0
    
    var leftMenu: UIViewController!
    var home: UIViewController!
    var rightMenu: UIViewController?
    var mainView: UIView!
    var tapGesture: UITapGestureRecognizer!
    var blackCover: UIView!
    var disableView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let image = self.backgroundImage {
            let imageView = UIImageView(frame: self.view.bounds)
            imageView.image = image
            self.view.addSubview(imageView)
        } else {
            self.view.backgroundColor = UIColor.greenColor()
        }
        
        if width > 320 {
            proportionOfLeftView = width / 320
            distanceOfLeftView += (width - 320) * FullDistance / 2
        }
        leftMenu.view.center = CGPoint(x: leftMenu.view.center.x - 50, y: leftMenu.view.center.y)
        leftMenu.view.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.8, 0.8)
        centerOfLeftViewAtBeginning = leftMenu.view.center
        
        self.view.addSubview(leftMenu.view)
        // 增加黑色遮罩层，实现视差特效
        blackCover = UIView(frame: CGRectOffset(self.view.frame, 0, 0))
        blackCover.backgroundColor = UIColor.blackColor()
        self.view.addSubview(blackCover)
        
        mainView = UIView(frame: self.view.frame)
        mainView.addSubview(home.view)
        
        self.view.addSubview(mainView)
        
        let panGesture = UIPanGestureRecognizer(target: self, action: "handlPan:")
        mainView.addGestureRecognizer(panGesture)
        
        tapGesture = UITapGestureRecognizer(target: self, action: "handlTap:")
        tapGesture.numberOfTouchesRequired = 1
        
        disableView = UIView(frame: self.view.frame)
        disableView.addGestureRecognizer(tapGesture)
        
    }
    
    
    func handlPan(pan: UIPanGestureRecognizer) {
        let x = pan.translationInView(self.view).x
        let trueDistance = distance + x
        let trueProportion = trueDistance / (width * FullDistance)
        //禁止左滑
        if trueDistance < 0 || trueProportion < 0 {
            return
        }
        DDLog.print("trueDistance = \(trueDistance) trueProportion = \(trueProportion)")
        DDLog.print("pan state_1 \(pan.state.rawValue)")
        let velocity = pan.velocityInView(mainView)
        let a = sqrt((velocity.x * velocity.x) + (velocity.y * velocity.y))
        DDLog.print("a = \(a)")
        if pan.state == .Ended || pan.state == .Cancelled || pan.state == .Failed || (pan.state == .Changed && a > 1500){
            DDLog.print("pan state_2 \(pan.state.rawValue)")
            
            if trueDistance > width * (Proportion / 3) {
                showLeftMenu()
                DDLog.print("showLeftMenu")
            } else if trueDistance < width * -(Proportion / 3) {
                showRightMenu()
                DDLog.print("showRightMenu")
            } else {
                showHome()
                DDLog.print("showHome")
            }
            return
        }
        
        // 计算缩放比例
        var proportion: CGFloat = pan.view!.frame.origin.x >= 0 ? -1 : 1
        proportion *= trueDistance / width
        proportion *= 1 - Proportion
        proportion /= FullDistance + Proportion/2 - 0.5
        proportion += 1
        if proportion <= Proportion { // 若比例已经达到最小，则不再继续动画
            return
        }
        // 执行视差特效
        blackCover.alpha = (proportion - Proportion) / (1 - Proportion)
        // 执行平移和缩放动画
        pan.view!.center = CGPointMake(self.view.center.x + trueDistance, self.view.center.y)
        pan.view!.transform = CGAffineTransformScale(CGAffineTransformIdentity, proportion, proportion)
        
        // 执行左视图动画
        let pro = 0.8 + (proportionOfLeftView - 0.8) * trueProportion
        leftMenu.view.center = CGPointMake(centerOfLeftViewAtBeginning.x + distanceOfLeftView * trueProportion, centerOfLeftViewAtBeginning.y - (proportionOfLeftView - 1) * leftMenu.view.frame.height * trueProportion / 2 )
        leftMenu.view.transform = CGAffineTransformScale(CGAffineTransformIdentity, pro, pro)
    }
    func handlTap(tap: UITapGestureRecognizer) {
//        mainView.addGestureRecognizer(tapGesture)
//        distance = self.view.center.x * (FullDistance * 2 + Proportion - 1)
        showHome()
        
    }
    // 展示左视图
    func showLeftMenu() {
//        mainView.addGestureRecognizer(tapGesture)
        distance = self.view.center.x * (FullDistance*2 + Proportion - 1)
        doTheAnimate(self.Proportion, showWhat: "left")
        self.disableView.frame = self.home.view.frame
        self.home.view.addSubview(self.disableView)
    }
    // 展示主视图
    func showHome() {
//        mainView.removeGestureRecognizer(tapGesture)
        distance = 0
        doTheAnimate(1, showWhat: "home")
        disableView.removeFromSuperview()
    }
    // 展示右视图
    func showRightMenu() {
//        mainView.addGestureRecognizer(tapGesture)
        distance = self.view.center.x * -(FullDistance*2 + Proportion - 1)
        doTheAnimate(self.Proportion, showWhat: "right")
    }
    
    func doTheAnimate(proportion: CGFloat, showWhat: String) {
        UIView.animateWithDuration(0.3, delay: 0, options: UIViewAnimationOptions.CurveEaseInOut, animations: { () -> Void in
            self.mainView.center = CGPointMake(self.view.center.x + self.distance, self.view.center.y)
            self.mainView.transform = CGAffineTransformScale(CGAffineTransformIdentity, proportion, proportion)
            if showWhat == "left" {
                self.leftMenu.view.center = CGPointMake(self.centerOfLeftViewAtBeginning.x + self.distanceOfLeftView, self.leftMenu.view.center.y)
                self.leftMenu.view.transform = CGAffineTransformScale(CGAffineTransformIdentity, self.proportionOfLeftView, self.proportionOfLeftView)
            }
            self.blackCover.alpha = showWhat == "home" ? 1 : 0
            self.leftMenu.view.alpha = showWhat == "right" ? 0 : 1
            }, completion: nil)
    }
    func setHomeController(home: UIViewController , animated: Bool = false) {
        if !animated {
            self.home.view.removeFromSuperview()
            self.home = home
            home.slideController = self
            mainView.addSubview(home.view)
        } else {
            UIView.animateWithDuration(0.15, delay: 0, options: UIViewAnimationOptions.CurveEaseInOut, animations: { () -> Void in
                self.home.view.alpha = 0.3
                }) { (_) -> Void in
                    self.home.view.removeFromSuperview()
                    self.home = home
                    home.slideController = self
                    home.view.alpha = 0.3
                    self.mainView.addSubview(home.view)
                    UIView.animateWithDuration(0.15, delay: 0, options: UIViewAnimationOptions.CurveEaseInOut, animations: { () -> Void in
                        home.view.alpha = 1
                        }, completion: nil)
            }
        }
    }
    convenience init?(left: UIViewController , home: UIViewController , right: UIViewController?) {
        self.init()
        self.leftMenu = left
        self.home = home
        self.rightMenu = right
        left.slideController = self
        right?.slideController = self
        home.slideController = self
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

extension UIViewController {
    var slideController: DTSlideController? {
        get {
            return objc_getAssociatedObject(self, &associatedObjectKey) as? DTSlideController
        }
        set {
            objc_setAssociatedObject(self, &associatedObjectKey, newValue, objc_AssociationPolicy(OBJC_ASSOCIATION_RETAIN))
        }
    }
}

