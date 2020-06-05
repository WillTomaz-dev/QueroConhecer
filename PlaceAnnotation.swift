//
//  PlaceAnnotation.swift
//  QueroConhecer
//
//  Created by William Tomaz on 02/06/20.
//  Copyright © 2020 William Tomaz. All rights reserved.
//

import Foundation
import MapKit

enum PlaceType {
    case place
    case poi
}

class PlaceAnnotation: NSObject, MKAnnotation {
    var coordinate: CLLocationCoordinate2D
    var title: String?
    var subtitle: String?
    var type: PlaceType
    var adress: String?
    
    init(coordinate: CLLocationCoordinate2D, type: PlaceType) {
        self.coordinate = coordinate
        self.type = type
    }
}
