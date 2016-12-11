//
//  AuthLocationManager.swift
//  CP
//
//  Created by Arnaud Verrier on 11/12/2016.
//  Copyright © 2016 Arnaud Verrier. All rights reserved.
//

import Foundation
import MapKit

protocol AuthLocationManagerProtocol {
    func retUserLocation(location:CLLocation?)
}

class AuthLocationManager:AuthManager, CLLocationManagerDelegate {
    
    let locationManager = CLLocationManager()
    var delegate:AuthLocationManagerProtocol?
    
    init(viewController:UIViewController?) {
        super.init()
        
        accepted = CLLocationManager.authorizationStatus() == .authorizedWhenInUse
        notDetermined = CLLocationManager.authorizationStatus() == .notDetermined
        authType = .location
        
        if let viewController = viewController {
            popUpManager = PopUpManager(presenting: viewController)
        }
        
        if notDetermined {
            self.askingAuth()
        }
        
        if accepted {
            locationManager.delegate = self
            locationManager.startUpdatingLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = manager.location {
            self.delegate?.retUserLocation(location: location)
            locationManager.stopUpdatingLocation()
        }
    }
    
    override func acceptAuth() {
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        
        if status == CLAuthorizationStatus.authorizedWhenInUse {
            locationManager.startUpdatingLocation()
        }
        self.popUpManager?.dimissPopUp()
    }
}
