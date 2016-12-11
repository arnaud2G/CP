//
//  AuthManager.swift
//  CP
//
//  Created by Arnaud Verrier on 11/12/2016.
//  Copyright © 2016 Arnaud Verrier. All rights reserved.
//

import Foundation
import MapKit

enum AuthType {
    case none, location
}

class AuthManager:NSObject, AuthViewControllerProtocol {
    
    var accepted:Bool
    var notDetermined:Bool
    
    var popUpManager:PopUpManager?
    
    var authType:AuthType
    
    convenience init(viewController:UIViewController?) {
        self.init()
        
        if let viewController = viewController {
            popUpManager = PopUpManager(presenting: viewController)
        }
    }
    
    override init() {
        
        accepted = false
        notDetermined = false
        authType = .none
        
        super.init()
    }
    
    func askingAuth() {
        
        guard let popUpManager = popUpManager else {return}
        
        let authViewController = AuthViewController(authType: authType)
        authViewController.delegate = self
        popUpManager.callPopUp(presented: authViewController)
    }
    
    func acceptAuth() {
        popUpManager!.dimissPopUp()
        print("Accepted")
    }
    
    func rejectAuth() {
        popUpManager!.dimissPopUp()
        print("Rejected")
    }
}


