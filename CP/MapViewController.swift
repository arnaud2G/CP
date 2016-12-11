//
//  ViewController.swift
//  CP
//
//  Created by Arnaud Verrier on 11/12/2016.
//  Copyright © 2016 Arnaud Verrier. All rights reserved.
//

import UIKit
import Mapbox

class MapViewController: UIViewController, MGLMapViewDelegate, AuthLocationManagerProtocol, UISearchBarDelegate {
    
    var authManager:AuthLocationManager!
    let point = MGLPointAnnotation()

    @IBOutlet var mapView: MGLMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        authManager = AuthLocationManager(viewController: self)
        authManager.delegate = self
        
        mapView.delegate = self
        mapView.addAnnotation(point)
        
        // On ajoute la fausse searchBar
        let searchBar = UISearchBar()
        searchBar.delegate = self
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        mapView.addSubview(searchBar)
        
        searchBar.leftAnchor.constraint(equalTo: mapView.leftAnchor, constant: 30).isActive = true
        searchBar.rightAnchor.constraint(equalTo: mapView.rightAnchor, constant: -30).isActive = true
        searchBar.topAnchor.constraint(equalTo: mapView.topAnchor, constant: 30).isActive = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        
        let searchAdress = SearchViewController(sender:searchBar)
        
        let popUpManager = PopUpManager(presenting: self)
        popUpManager.callPopUp(presented: searchAdress, transition: UIModalTransitionStyle.crossDissolve)
        return false
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

