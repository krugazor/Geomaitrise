//  RamerDouglasPeucker 
//  Geomaitrise
//
//  Copyright © 2019 Nicolas Zinovieff. MIT Licence.
//

import Foundation

typealias Point = (x: Double, y: Double)

func distance(p1: Point, p2: Point) -> Double {
    return sqrt((p2.y-p1.y)*(p2.y-p1.y)+(p2.x-p1.x)*(p2.x-p1.x))
    
} // pow est trop lent

func getLineParameters(point1: Point, point2: Point) -> (a: Double, b: Double, c: Double) {
    let a = point1.y - point2.y
    let b = point2.x - point1.x
    let c = ((-b)*point1.y) + ((-a)*point1.x) // eeeeeeeet oui
    return (a,b,c)
}

func getPerpendicularDistance(line: (a: Double, b: Double, c: Double), point: Point) -> Double {
    let num = abs(line.a * point.x + line.b * point.y + line.c)
    let den = sqrt(line.a * line.a + line.b * line.b)
    return num/den
}

func douglaspeuckerSimplification(line: [Point], epsilon: Double) -> [Point] {
    if line.count <= 2 { return [line.first!, line.last!] }
    // Find the point with the maximum distance
    var dmax : Double = 0
    var index = 0
    let (a,b,c) = getLineParameters(point1: line.first!, point2: line.last!)
    for i in 1..<(line.count-1) {
        let d = getPerpendicularDistance(line: (a,b,c), point: line[i])
        if dmax < d {
            dmax = d
            index = i
        }
    }
    if dmax > epsilon {
        let sub1 = Array(line[0..<index+1])
        let sub2 = Array(line[index..<line.count])
        let res1 = douglaspeuckerSimplification(line: sub1 , epsilon: epsilon)
        var res2 = douglaspeuckerSimplification(line: sub2, epsilon: epsilon)
        res2 = Array(res2.dropFirst())
        return res1 + res2
    } else {
        return [line.first!, line.last!]
    }
}


