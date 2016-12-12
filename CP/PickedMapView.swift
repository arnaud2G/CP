//
//  PickedMapView.swift
//  CP
//
//  Created by 2Gather Arnaud Verrier on 12/12/2016.
//  Copyright © 2016 Arnaud Verrier. All rights reserved.
//

import Foundation
import UIKit
import Mapbox
import MapKit

// Ici on ajoute les types disponibles
enum MapType {
    case MapBox
}

// Protocol pour retourner la location du pins
protocol PickedMapViewProtocol {
    func regionChanging(latitude:Double, longitude:Double)
}

// Protocol pour communiquer avec le ViewController
protocol MapViewManagerProtocol {
    func searchingLocation(sender:UIView, latitude:Double, longitude:Double)
    func searchingFavorites(sender:UIView)
}

class MapViewManager:NSObject, PickedMapViewProtocol {
    
    var delegate:MapViewManagerProtocol?
    
    var vMap:UIView!
    let searchBar = UISearchBar()
    
    var latitude:Double?
    var longitude:Double?
    
    init(type:MapType, includedIn:UIView) {
        super.init()
        
        // En fonction du type on va chercher une map différente
        switch type {
        case .MapBox:
            vMap = PickedMapBox(pickedMapViewProtocol: self)
        }
        
        vMap.translatesAutoresizingMaskIntoConstraints = false
        includedIn.addSubview(vMap)
        vMap.leftAnchor.constraint(equalTo: includedIn.leftAnchor).isActive = true
        vMap.rightAnchor.constraint(equalTo: includedIn.rightAnchor).isActive = true
        vMap.topAnchor.constraint(equalTo: includedIn.topAnchor).isActive = true
        vMap.bottomAnchor.constraint(equalTo: includedIn.bottomAnchor).isActive = true
        
        // On ajoute la fausse searchBar
        searchBar.delegate = self
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        vMap.addSubview(searchBar)
        searchBar.barTintColor = .lightGray
        
        // On ajoute le bouton favorite
        let btnFavorites = UIButton()
        btnFavorites.translatesAutoresizingMaskIntoConstraints = false
        vMap.addSubview(btnFavorites)
        btnFavorites.backgroundColor = .lightGray
        btnFavorites.tintColor = .white
        btnFavorites.imageEdgeInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        btnFavorites.setImage(UIImage(named: "favorites")!.withRenderingMode(.alwaysTemplate), for: .normal)
        btnFavorites.addTarget(self, action: #selector(self.printFavorite(send:)), for: .touchUpInside)
        btnFavorites.widthAnchor.constraint(equalTo: btnFavorites.heightAnchor).isActive = true
        btnFavorites.heightAnchor.constraint(equalTo: searchBar.heightAnchor).isActive = true
        
        // On place les éléments
        searchBar.leftAnchor.constraint(equalTo: vMap.leftAnchor, constant: 30).isActive = true
        searchBar.rightAnchor.constraint(equalTo: btnFavorites.leftAnchor).isActive = true
        btnFavorites.rightAnchor.constraint(equalTo: vMap.rightAnchor, constant: -30).isActive = true
        btnFavorites.topAnchor.constraint(equalTo: searchBar.topAnchor).isActive = true
        searchBar.topAnchor.constraint(equalTo: vMap.topAnchor, constant: 50).isActive = true
    }
    
    // On delegue l'affichage au view controller
    func printFavorite(send:UIButton) {
        self.delegate?.searchingFavorites(sender: searchBar)
    }
    
    // Le timer évite des recherche multiple
    var gameTimer:Timer?
    func addStartingPoint(latitude:Double, longitude:Double) {
        self.latitude = latitude
        self.longitude = longitude
        (vMap as! UsingMapProtocol).addPoint(latitude: latitude, longitude: longitude)
        gameTimer?.invalidate()
        gameTimer = Timer.scheduledTimer(timeInterval: 3, target: self, selector: #selector(self.reverseGeo), userInfo: nil, repeats: false)
    }
    
    internal func regionChanging(latitude: Double, longitude: Double) {
        self.latitude = latitude
        self.longitude = longitude
        gameTimer?.invalidate()
        gameTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.reverseGeo), userInfo: nil, repeats: false)
    }
     
    // On cherche un endroit a partir de coordonnées // CLGeocoder est pas terrible ...
    func reverseGeo() {
        
        let location = CLLocation(latitude: self.latitude!, longitude: self.longitude!)
        
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
extension MapViewManager: UISearchBarDelegate {
    
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        self.delegate?.searchingLocation(sender:searchBar, latitude: self.latitude!, longitude: self.longitude!)
        return false
    }
}

// MARK: - Protocol imposer our l'utilisation de nouvelle map
protocol UsingMapProtocol {
    var pickedMapViewProtocol:PickedMapViewProtocol? { get }
    func addPoint(latitude: Double, longitude: Double)
}

// MARK: - Gestion avec MAPBOX
class PickedMapBox:MGLMapView, UsingMapProtocol, MGLMapViewDelegate {
    
    let point = MGLPointAnnotation()
    
    internal func addPoint(latitude: Double, longitude: Double) {
        point.coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        self.latitude = latitude
        self.longitude = longitude
    }
    
    var pickedMapViewProtocol: PickedMapViewProtocol?
    
    convenience init(pickedMapViewProtocol: PickedMapViewProtocol) {
        self.init(frame: UIScreen.main.bounds)
        
        self.delegate = self
        
        self.pickedMapViewProtocol = pickedMapViewProtocol
        self.addAnnotation(point)
        self.zoomLevel = 14
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func mapViewRegionIsChanging(_ mapView: MGLMapView) {
        point.coordinate = mapView.centerCoordinate
        self.pickedMapViewProtocol?.regionChanging(latitude: mapView.latitude, longitude: mapView.longitude)
    }
}




