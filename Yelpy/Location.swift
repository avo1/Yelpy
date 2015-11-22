//
//  Location.swift
//  Yelpy
//
//  Created by Dave Vo on 11/22/15.
//  Copyright © 2015 Dave Vo. All rights reserved.
//

import Foundation
import MapKit

class Location: NSObject, MKAnnotation {
  var title: String?
  var coordinate: CLLocationCoordinate2D
  var info: String
  
  init(title: String, coordinate: CLLocationCoordinate2D, info: String) {
    self.title = title
    self.coordinate = coordinate
    self.info = info
  }
}
