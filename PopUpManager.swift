//
//  PopUpManager.swift
//  CP
//
//  Created by Arnaud Verrier on 11/12/2016.
//  Copyright © 2016 Arnaud Verrier. All rights reserved.
//

import Foundation
import UIKit

protocol PopUpManagerProtocol:class {
    func dismisPopUp()
}

class PopUpManager:NSObject {
    
    var presenting:UIViewController!
    var presented:UIViewController?
    var bView:UIView!
    
    convenience init(presenting:UIViewController) {
        self.init()
        
        self.presenting = presenting
    }
    
    override init() {
        super.init()
    }
    
    func callPopUp(presented:UIViewController, transition:UIModalTransitionStyle? = nil, completionHandler:(() -> Void)? = nil) {
        
        if self.presented != nil {
            self.presented = presented
            changePopUp(transition: transition, completionHandler: completionHandler)
        } else {
            self.presented = presented
            newPopUp(transition: transition, completionHandler: completionHandler)
        }
    }
    
    private func newPopUp(transition:UIModalTransitionStyle?, completionHandler:(() -> Void)? = nil) {
        
        guard let presented = self.presented else {fatalError("Cela ne peut pas arriver")}
        
        bView = UIView(frame: UIScreen.main.bounds)
        bView.backgroundColor = UIColor(white: 0.0, alpha: 0.0)
        
        if let existingNavigationController = self.presenting.navigationController {
            existingNavigationController.view.addSubview(bView)
        } else {
            presenting.view.addSubview(bView)
        }
        
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.5, delay: 0.0, usingSpringWithDamping: 2.0, initialSpringVelocity: 0.1, options: UIViewAnimationOptions.curveEaseInOut, animations: {
                self.bView.backgroundColor = .darkGray
            }, completion: nil
            )
            
            presented.modalPresentationStyle = .overCurrentContext
            presented.modalPresentationCapturesStatusBarAppearance = true
            if let transition = transition {
                presented.modalTransitionStyle = transition
            }
            
            if let existingNavigationController = self.presenting.navigationController {
                existingNavigationController.present(presented, animated: true, completion: completionHandler )
            } else {
                self.presenting.present(presented, animated: true, completion: completionHandler)
            }
        }
    }
    
    private func changePopUp(transition:UIModalTransitionStyle?, completionHandler:(() -> Void)? = nil) {
        
        guard let presented = self.presented else {return}
        
        DispatchQueue.main.async {
            
            presented.modalPresentationCapturesStatusBarAppearance = true
            
            self.presenting.navigationController!.dismiss(animated: false, completion: {
                presented.modalPresentationStyle = .overCurrentContext
                
                if let existingNavigationController = self.presenting.navigationController {
                    existingNavigationController.present(presented, animated: true, completion: completionHandler )
                } else {
                    self.presenting.present(presented, animated: true, completion: completionHandler)
                }
            })
        }
    }
    
    func dimissPopUp(completionHandler:(() -> Void)? = nil) {
        
        guard self.presented != nil else {return}
        
        DispatchQueue.main.async {
            
            UIView.animate(withDuration: 0.5, delay: 0.0, usingSpringWithDamping: 2.0, initialSpringVelocity: 0.1, options: UIViewAnimationOptions.curveEaseInOut, animations: {
                self.bView.backgroundColor = UIColor(white: 0.0, alpha: 0.0)
            }, completion: {
                res in
                self.bView.removeFromSuperview()
            }
            )
            
            self.presented = nil
            if let existingNavigationController = self.presenting.navigationController {
                existingNavigationController.dismiss(animated: true, completion: completionHandler)
            } else {
                self.presenting.dismiss(animated: true, completion: completionHandler)
            }
        }
    }
    
    func closePopUp(completionHandler:(() -> Void)? = nil) {
        
        guard self.presented != nil else {return}
        
        DispatchQueue.main.async {
            
            self.bView.removeFromSuperview()
            
            self.presented = nil
            if let existingNavigationController = self.presenting.navigationController {
                existingNavigationController.dismiss(animated: true, completion: completionHandler)
            } else {
                self.presenting.dismiss(animated: true, completion: completionHandler)
            }
        }
    }
}


