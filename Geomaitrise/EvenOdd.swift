//  EvenOdd
//
//  Geomaitrise
//
//  Copyright © 2019 Nicolas Zinovieff. MIT Licence.
//

import Foundation

typealias Polygon = [Point]

func evenOdd(_ point: Point, in poly: Polygon) -> Bool {
    var inside = false
    var j = poly.count - 1
    for i in 0..<poly.count {
        if (poly[i].y > point.y) != (poly[j].y > point.y)
            && ( point.x < poly[i].x + ( poly[j].x - poly[i].x ) * ( point.y - poly[i].y) / (poly[j].y - poly[i].y) ) {
            inside = !inside
        }
        j = i
    }
    
    return inside
}
