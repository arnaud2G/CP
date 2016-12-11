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

class SearchViewController:UIViewController {
    
    var locations = [Location]()
    
    let tvLocation = UITableView()
    
    convenience init(sender:UISearchBar) {
        self.init(nibName: nil, bundle: nil)
        
        let sbLocation = UISearchBar()
        sbLocation.delegate = self
        sbLocation.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(sbLocation)
        
        sbLocation.leftAnchor.constraint(equalTo: self.view.leftAnchor, constant: sender.frame.origin.x).isActive = true
        sbLocation.topAnchor.constraint(equalTo: self.view.topAnchor, constant: sender.frame.origin.y).isActive = true
        sbLocation.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        sbLocation.heightAnchor.constraint(equalToConstant: sender.frame.size.height).isActive = true
        sbLocation.becomeFirstResponder()
        
        tvLocation.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(tvLocation)
        
        tvLocation.delegate = self
        tvLocation.dataSource = self
        
        tvLocation.register(LocationCell.self, forCellReuseIdentifier: "LocationCell")
        tvLocation.separatorStyle = .none
        tvLocation.backgroundColor = .clear
        
        tvLocation.leftAnchor.constraint(equalTo: sbLocation.leftAnchor).isActive = true
        tvLocation.rightAnchor.constraint(equalTo: sbLocation.rightAnchor).isActive = true
        tvLocation.topAnchor.constraint(equalTo: sbLocation.bottomAnchor, constant: 10).isActive = true
        tvLocation.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -1*sender.frame.origin.y).isActive = true
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
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        print(searchText)
        search(location: searchText)
    }
    
    func search(location:String) {
        
        let localSearchRequest = MKLocalSearchRequest()
        localSearchRequest.naturalLanguageQuery = location
        
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
            return Location(title: mapItem.name, adress: mapItem.placemark.title, latitude: mapItem.placemark.coordinate.latitude, longitude: mapItem.placemark.coordinate.latitude)
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
        
        lblName.translatesAutoresizingMaskIntoConstraints = false
        lblAdress.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(lblName)
        contentView.addSubview(lblAdress)
        
        // ON AJOUTE LES CONTRAINTES
        lblName.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        lblAdress.topAnchor.constraint(equalTo: lblName.bottomAnchor).isActive = true
        lblAdress.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        
        lblName.leftAnchor.constraint(equalTo: self.leftAnchor).isActive = true
        lblName.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
        lblAdress.leftAnchor.constraint(equalTo: self.leftAnchor).isActive = true
        lblAdress.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
        
        // ON AJOUTE LES ATTRIBUTES
        lblName.textColor = .red
        lblName.font = UIFont(name: lblName.font.fontName, size: 24)
        
        lblAdress.numberOfLines = 0
        lblAdress.textColor = .darkGray
        lblName.font = UIFont(name: lblName.font.fontName, size: 18)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func addLocation(location:Location) {
        
        lblName.text = location.title
        lblAdress.text = location.adress
    }
}




