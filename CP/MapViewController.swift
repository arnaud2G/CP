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

class MapViewController: UIViewController, MGLMapViewDelegate, AuthLocationManagerProtocol, UISearchBarDelegate {
    
    var authManager:AuthLocationManager!
    let point = MGLPointAnnotation()

    @IBOutlet var mapView: MGLMapView!
    let searchBar = UISearchBar()
    
    var popUpManager:PopUpManager!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Gest des popUp
        popUpManager = PopUpManager(presenting: self)
        
        // Gestion de la localisation
        authManager = AuthLocationManager(viewController: self)
        authManager.delegate = self
        
        // Gestion de la Map
        mapView.delegate = self
        mapView.addAnnotation(point)
        
        // On ajoute la fausse searchBar
        searchBar.delegate = self
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        mapView.addSubview(searchBar)
        searchBar.barTintColor = .lightGray
        
        // On ajoute le bouton favorite
        let btnFavorites = UIButton()
        btnFavorites.translatesAutoresizingMaskIntoConstraints = false
        mapView.addSubview(btnFavorites)
        btnFavorites.backgroundColor = .lightGray
        btnFavorites.tintColor = .white
        btnFavorites.imageEdgeInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        btnFavorites.setImage(UIImage(named: "favorites")!.withRenderingMode(.alwaysTemplate), for: .normal)
        btnFavorites.addTarget(self, action: #selector(self.printFavorite(send:)), for: .touchUpInside)
        btnFavorites.widthAnchor.constraint(equalTo: btnFavorites.heightAnchor).isActive = true
        btnFavorites.heightAnchor.constraint(equalTo: searchBar.heightAnchor).isActive = true
        
        // On place les éléments
        searchBar.leftAnchor.constraint(equalTo: mapView.leftAnchor, constant: 30).isActive = true
        searchBar.rightAnchor.constraint(equalTo: btnFavorites.leftAnchor).isActive = true
        btnFavorites.rightAnchor.constraint(equalTo: mapView.rightAnchor, constant: -30).isActive = true
        btnFavorites.topAnchor.constraint(equalTo: searchBar.topAnchor).isActive = true
        searchBar.topAnchor.constraint(equalTo: mapView.topAnchor, constant: 50).isActive = true
    }
    
    func printFavorite(send:UIButton) {
        
        do {
            let locations = try LocationStorage.sharedInstance.getAllData()
            let searchAdress = SearchViewController(sender:searchBar, locations: Location.convertLocationCD(locations: locations))
            searchAdress.delegate = self
            popUpManager.callPopUp(presented: searchAdress, transition: UIModalTransitionStyle.crossDissolve)
        } catch {
            // Gestion de l'err ici
        }
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
    
    // Gestion de la map
    func mapViewRegionIsChanging(_ mapView: MGLMapView) {
        point.coordinate = CLLocationCoordinate2D(latitude: mapView.latitude, longitude: mapView.longitude)
    }
    
    func mapViewDidFinishLoadingMap(_ mapView: MGLMapView) {
        point.coordinate = CLLocationCoordinate2D(latitude: mapView.latitude, longitude: mapView.longitude)
    }
    
    // On ajoute un timer pour éviter les recherches multiples
    var gameTimer:Timer?
    func mapViewDidFinishRenderingMap(_ mapView: MGLMapView, fullyRendered: Bool) {
        // TODO: Marqueur de recherche sur le pin
        gameTimer?.invalidate()
        gameTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.reverseGeo), userInfo: nil, repeats: false)
    }
    
    // On cherche un endroit a partir de coordonnées
    func reverseGeo() {
        
        let location = CLLocation(latitude: mapView.latitude, longitude: mapView.longitude)
        
        let geoCoder = CLGeocoder()
        geoCoder.reverseGeocodeLocation(location, completionHandler: {
            (placemarks, error) -> Void in
            
            if let placeMark = placemarks?.first {
                
                var reverseGeo = String()
                
                // Location name
                if let locationName = placeMark.addressDictionary!["Name"] as? String {
                    reverseGeo = "\(reverseGeo) - \(locationName)"
                }
                
                // City
                if let city = placeMark.addressDictionary!["City"] as? String {
                    reverseGeo = "\(reverseGeo) - \(city)"
                }
                
                // Zip code
                if let zip = placeMark.addressDictionary!["ZIP"] as? String {
                    reverseGeo = "\(reverseGeo) - \(zip)"
                }
                
                // Country
                if let country = placeMark.addressDictionary!["Country"] as? String {
                    reverseGeo = "\(reverseGeo) - \(country)"
                }
                
                do {
                    try LocationStorage.sharedInstance.addLocation(location: Location(title: placeMark.addressDictionary!["Name"] as? String, adress: placeMark.addressDictionary!["City"] as? String, latitude: location.coordinate.latitude, longitude: location.coordinate.longitude))
                } catch {
                    // Gestion de l'err ici
                }
                
                self.searchBar.text = reverseGeo
            }
        })
    }
}

// Gestion de la bar de recherche
extension MapViewController: SearchViewControllerProtocol {
    
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        
        let searchAdress = SearchViewController(sender:searchBar, userRegion:MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: mapView.latitude, longitude: mapView.longitude), span: MKCoordinateSpan(latitudeDelta: 5, longitudeDelta: 5)))
        searchAdress.delegate = self
        
        popUpManager.callPopUp(presented: searchAdress, transition: UIModalTransitionStyle.crossDissolve)
        return false
    }
    
    func cancelSearch() {
        popUpManager.dimissPopUp()
    }
    
    func selectLocation(location:Location) {
        popUpManager.dimissPopUp()
        mapView.latitude = location.latitude
        mapView.longitude = location.longitude
        point.coordinate = CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude)
    }
}

