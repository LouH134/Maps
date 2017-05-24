//
//  LHAnnotation.swift
//  Map
//
//  Created by Louis Harris on 5/15/17.
//  Copyright © 2017 Louis Harris. All rights reserved.
//

import UIKit
import MapKit

class LHAnnotation: NSObject, MKAnnotation {// put in extension later

    var coordinate: CLLocationCoordinate2D
    //title
    var title: String?
    //subtitle
    var subtitle: String?
    //image
    var image: UIImage?
    
    var url: String?
    
    init(coordinate: CLLocationCoordinate2D){
        self.coordinate = coordinate
    }

    
}

//extension LHAnnotation : MKAnnotation {
//    
//    
//    
//    
//}
