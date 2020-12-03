//
//  LoadingScreen.swift
//  Easy Cook
//
//  Created by Kua Jun Hong on 02/12/2020.
//

import UIKit
import Lottie

class LoadingScreen: NSObject {
    
    var overlayView: UIView? = UIView()
    var progressLabel = UILabel()
    var animationView = AnimationView()
    
    class var shared: LoadingScreen {
        struct Static {
            static let instance: LoadingScreen = LoadingScreen()
        }
        return Static.instance
    }
    
    public func showOverlay(view: UIViewController?, userInteract: Bool = false, stackView: Bool = false) {
        
        if(!animationView.isAnimationPlaying){
            Util.runInMainThread {
                self.overlayView = UIView(frame: UIScreen.main.bounds)
                self.overlayView?.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.5)
                self.overlayView?.tag = 101

                self.animationView.animation = Animation.named("39067-loading")
                self.animationView.frame = CGRect(x: 0.0, y: 0.0, width: 200, height:  150)
                self.animationView.center = CGPoint(x: view!.view.bounds.width / 2.0, y: view!.view.bounds.height / 2.0)
                self.animationView.loopMode = .loop
                self.overlayView?.addSubview(self.animationView)
                
                view?.view.addSubview(self.overlayView!)
                self.animationView.play()
                
                if(!userInteract){
                    print("User interact set to false")
                    view?.view.isUserInteractionEnabled = false
                    
                    UIApplication.shared.beginIgnoringInteractionEvents()
                }
            }
        }
    }
    
    public func hideOverlayView(view: UIViewController?) {
        Util.runInMainThread {
            self.overlayView?.isHidden = true
            if let subview = view?.view.viewWithTag(101) {
                subview.removeFromSuperview()
            } else {
                self.overlayView!.removeFromSuperview()
            }
            self.animationView.stop()

            UIApplication.shared.endIgnoringInteractionEvents()
            
            view?.view.isUserInteractionEnabled = true
            print("User interact set to true")
        }
    }
}
