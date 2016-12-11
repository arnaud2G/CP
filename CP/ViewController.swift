//
//  ViewController.swift
//  CP
//
//  Created by Arnaud Verrier on 11/12/2016.
//  Copyright © 2016 Arnaud Verrier. All rights reserved.
//

import UIKit
import Mapbox

class ViewController: UIViewController, MGLMapViewDelegate, CLLocationManagerDelegate, AuthLocationManagerProtocol {
    
    var authManager:AuthLocationManager!
    let point = MGLPointAnnotation()

    @IBOutlet var mapView: MGLMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        authManager = AuthLocationManager(viewController: self)
        authManager.delegate = self
        
        mapView.delegate = self
        
        mapView.addAnnotation(point)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func retUserLocation(location: CLLocation?) {
        
        if let location = location {
            mapView.latitude = location.coordinate.latitude
            mapView.longitude = location.coordinate.longitude
            mapView.zoomLevel = 14
            
            point.coordinate = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        }
    }
    
    func mapViewRegionIsChanging(_ mapView: MGLMapView) {
        point.coordinate = CLLocationCoordinate2D(latitude: mapView.latitude, longitude: mapView.longitude)
    }
    
    func mapViewDidFinishLoadingMap(_ mapView: MGLMapView) {
        point.coordinate = CLLocationCoordinate2D(latitude: mapView.latitude, longitude: mapView.longitude)
    }
}

