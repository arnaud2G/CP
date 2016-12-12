//
//  PickedMapView.swift
//  CP
//
//  Created by 2Gather Arnaud Verrier on 12/12/2016.
//  Copyright © 2016 Arnaud Verrier. All rights reserved.
//

import Foundation
import UIKit

protocol PickedMapViewProtocol {
    func regionChanging(latitude:Double, longitude:Double)
    func mapLoadded(latitude:Double, longitude:Double)
    func mapRendering(latitude:Double, longitude:Double)
}

class PickedMapView:UIView {
    
    var delegate:PickedMapViewProtocol?
    
    var latitude:Double?
    var longitude:Double?
    
    func addCenterPin(latitude:Double, longitude:Double) {
        // Ici on alimente le point de la map
    }
}
