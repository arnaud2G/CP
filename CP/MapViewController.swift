//
//  ViewController.swift
//  CP
//
//  Created by Arnaud Verrier on 11/12/2016.
//  Copyright © 2016 Arnaud Verrier. All rights reserved.
//

import UIKit
import Mapbox
import MapKit

class MapViewController: UIViewController, AuthLocationManagerProtocol, MapViewManagerProtocol/*, UISearchBarDelegate, PickedMapViewProtocol*/ {
    
    var authManager:AuthLocationManager!
    var mapViewManager:MapViewManager!
    
    @IBOutlet var vMap: UIView!
    
    var popUpManager:PopUpManager!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Gest des popUp
        popUpManager = PopUpManager(presenting: self)
        
        // Gestion de la localisation
        authManager = AuthLocationManager(viewController: self)
        authManager.delegate = self
        
        // Gestion de la Map
        mapViewManager = MapViewManager(type: .MapBox, includedIn: vMap)
        mapViewManager.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func searchingLocation(sender:UIView, latitude: Double, longitude: Double) {
        
        
        let searchAdress = SearchViewController(sender:sender, userRegion:MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: latitude, longitude: longitude), span: MKCoordinateSpan(latitudeDelta: 5, longitudeDelta: 5)))
        searchAdress.delegate = self
        popUpManager.callPopUp(presented: searchAdress, transition: UIModalTransitionStyle.crossDissolve)
    }
    
    func searchingFavorites(sender: UIView) {
        
        do {
            let locations = try LocationStorage.sharedInstance.getAllData()
            let searchAdress = SearchViewController(sender:sender, locations: Location.convertLocationCD(locations: locations))
            searchAdress.delegate = self
            popUpManager.callPopUp(presented: searchAdress, transition: UIModalTransitionStyle.crossDissolve)
        } catch {
            // Gestion de l'err ici
        }
    }
    
    func retUserLocation(location: CLLocation?) {
        
        if let location = location {
            mapViewManager.addStartingPoint(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        }
    }
}

// Gestion de la bar de recherche
extension MapViewController: SearchViewControllerProtocol {
    
    func cancelSearch() {
        popUpManager.dimissPopUp()
    }
    
    func selectLocation(location:Location) {
        mapViewManager.addStartingPoint(latitude: location.latitude, longitude: location.longitude)
        popUpManager.dimissPopUp()
    }
}

