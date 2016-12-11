//
//  SearchViewController.swift
//  CP
//
//  Created by 2Gather Arnaud Verrier on 11/12/2016.
//  Copyright © 2016 Arnaud Verrier. All rights reserved.
//

import Foundation
import UIKit
import MapKit

protocol SearchViewControllerProtocol {
    func cancelSearch()
    func selectLocation(location:Location)
}

class SearchViewController:UIViewController {
    
    var userRegion:MKCoordinateRegion?
    
    var locations = [Location]()
    
    let tvLocation = UITableView()
    
    var delegate:SearchViewControllerProtocol?
    
    convenience init(sender:UISearchBar, userRegion:MKCoordinateRegion? = nil) {
        self.init(nibName: nil, bundle: nil)
        
        self.userRegion = userRegion
        
        // Ajout de la bar de recherche
        let sbLocation = UISearchBar()
        sbLocation.delegate = self
        sbLocation.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(sbLocation)
        
        sbLocation.rightAnchor.constraint(equalTo: self.view.rightAnchor, constant: sender.frame.origin.x).isActive = true
        sbLocation.topAnchor.constraint(equalTo: self.view.topAnchor, constant: sender.frame.origin.y).isActive = true
        sbLocation.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        sbLocation.heightAnchor.constraint(equalToConstant: sender.frame.size.height).isActive = true
        sbLocation.showsCancelButton = true
        sbLocation.becomeFirstResponder()
        
        // Ajout de la table d'affichage des résultats
        tvLocation.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(tvLocation)
        
        tvLocation.delegate = self
        tvLocation.dataSource = self
        
        tvLocation.register(LocationCell.self, forCellReuseIdentifier: "LocationCell")
        tvLocation.backgroundColor = .clear
        tvLocation.separatorStyle = .none
        tvLocation.estimatedRowHeight = 100
        
        tvLocation.leftAnchor.constraint(equalTo: sbLocation.leftAnchor).isActive = true
        tvLocation.rightAnchor.constraint(equalTo: sbLocation.rightAnchor).isActive = true
        tvLocation.topAnchor.constraint(equalTo: sbLocation.bottomAnchor, constant: 10).isActive = true
        tvLocation.bottomAnchor.constraint(equalTo: self.view.centerYAnchor).isActive = true
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Ici in travaille sur l'autocompletion
extension SearchViewController: UISearchBarDelegate {
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.delegate?.cancelSearch()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        search(location: searchText)
    }
    
    func search(location:String) {
        
        let localSearchRequest = MKLocalSearchRequest()
        localSearchRequest.naturalLanguageQuery = location
        if let userRegion = userRegion {
            localSearchRequest.region = MKCoordinateRegion(center: userRegion.center, span: userRegion.span)
        }
        
        let localSearch = MKLocalSearch(request: localSearchRequest)
        localSearch.start {
            (localSearchResponse, error) -> Void in
            
            if let localSearchResponse = localSearchResponse {
                self.locations = Location.convertSearchResponse(searchResponse:localSearchResponse.mapItems)
                self.tvLocation.reloadData()
            } else {
                self.locations = [Location]()
                self.tvLocation.reloadData()
            }
        }
    }
 }


// MARK: - Ici in travaille sur l'affichage de la table
extension SearchViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return locations.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "LocationCell") as! LocationCell
        cell.addLocation(location: locations[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("Touch")
        self.delegate?.selectLocation(location: locations[indexPath.row])
    }
}


class Location {
    
    let title:String?
    let adress:String?
    let latitude:Double
    let longitude:Double
    
    init(title:String?, adress:String?, latitude:Double, longitude:Double) {
        self.title = title
        self.adress = adress
        self.latitude = latitude
        self.longitude = longitude
    }
    
    static func convertSearchResponse(searchResponse:[MKMapItem]) -> [Location] {
        return searchResponse.map({
            (mapItem:MKMapItem) -> Location in
            return Location(title: mapItem.name, adress: mapItem.placemark.title, latitude: mapItem.placemark.coordinate.latitude, longitude: mapItem.placemark.coordinate.longitude)
        })
    }
}

class LocationCell: UITableViewCell {
    
    let lblName = UILabel()
    let lblAdress = UILabel()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        // On force les couleurs de fond transpoarent
        contentView.backgroundColor = .clear
        
        let vSep = UIView()
        let vPuce = UIView()
        
        vSep.translatesAutoresizingMaskIntoConstraints = false
        vPuce.translatesAutoresizingMaskIntoConstraints = false
        lblName.translatesAutoresizingMaskIntoConstraints = false
        lblAdress.translatesAutoresizingMaskIntoConstraints = false
        
        self.addSubview(vSep)
        self.addSubview(vPuce)
        self.addSubview(lblName)
        self.addSubview(lblAdress)
        
        // ON AJOUTE LES CONTRAINTES
        vPuce.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        lblName.topAnchor.constraint(equalTo: self.topAnchor, constant : 5).isActive = true
        lblAdress.topAnchor.constraint(equalTo: lblName.bottomAnchor).isActive = true
        lblAdress.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant : -5).isActive = true
        vSep.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        vSep.heightAnchor.constraint(equalToConstant: 1).isActive = true
        
        vPuce.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 10).isActive = true
        vPuce.widthAnchor.constraint(equalToConstant: 5).isActive = true
        vPuce.widthAnchor.constraint(equalTo: vPuce.heightAnchor).isActive = true
        vPuce.layer.cornerRadius = 2.5
        vPuce.backgroundColor = .darkGray
        
        lblName.leftAnchor.constraint(equalTo: vPuce.rightAnchor, constant: 10).isActive = true
        lblName.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
        lblAdress.leftAnchor.constraint(equalTo: vPuce.rightAnchor, constant: 10).isActive = true
        lblAdress.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
        vSep.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 20).isActive = true
        vSep.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
        
        // ON AJOUTE LES ATTRIBUTES
        lblName.textColor = .red
        lblName.font = UIFont(name: lblName.font.fontName, size: 20)
        
        lblAdress.numberOfLines = 0
        lblAdress.textColor = .darkGray
        lblAdress.font = UIFont(name: lblName.font.fontName, size: 14)
        
        vSep.backgroundColor = .darkGray
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func addLocation(location:Location) {
        
        lblName.text = location.title
        lblAdress.text = location.adress
    }
}




