//
//  MapCalculator.swift
//  MusicDiscovery
//
//  Created by Dillon McCusker on 4/15/15.
//  Copyright (c) 2015 Nick Martinson. All rights reserved.
//

import Foundation
import Darwin

class MapCalculator {
    let toDegrees = (180/M_PI)
    let toRadians = (M_PI/180)
    
    let numPoints:Int = 10
    let sweepAngle:Double = 90.0
    
    var closeAngle:Double = 45.0
    var farAngle:Double = 30.0
    
    let locHandler = LocationHandler.sharedInstance
    
    let earthRad: Double = 6371000 //Earth's radius in meters

    var loc2D: CLLocationCoordinate2D!
    
    var distance: Double!
    var rawBearing: CLHeading!
    var bearing: Double!
    var startLat: Double!
    var startLong: Double!
    
    func initRadianValues() {
        loc2D = locHandler.location2D
    
        distance = 500
        rawBearing = locHandler.bearing
        bearing = rawBearing.magneticHeading * toRadians as Double
        startLat  = loc2D.latitude * toRadians as Double
        startLong = loc2D.longitude * toRadians as Double
    }
    
//    func initCloseLeftRadianValues() {
//        loc2D = locHandler.location2D
//        
//        distance = 750
//        rawBearing = locHandler.bearing
//        bearing = rawBearing.magneticHeading * toRadians as Double
//        startLat  = loc2D.latitude * toRadians as Double
//        startLong = loc2D.longitude * toRadians as Double
//    }
//
//    func initCloseRightRadianValues() {
//        loc2D = locHandler.location2D
//        
//        distance = 750
//        rawBearing = locHandler.bearing
//        bearing = rawBearing.magneticHeading * toRadians as Double
//        startLat  = loc2D.latitude * toRadians as Double
//        startLong = loc2D.longitude * toRadians as Double
//    }
//    
//    func initFarLeftRadianValues() {
//        loc2D = locHandler.location2D
//        
//        distance = 1000
//        rawBearing = locHandler.bearing
//        bearing = rawBearing.magneticHeading * toRadians as Double
//        startLat  = loc2D.latitude * toRadians as Double
//        startLong = loc2D.longitude * toRadians as Double
//    }
//    
//    func initFarRightRadianValues() {
//        loc2D = locHandler.location2D
//        
//        distance = 1000
//        rawBearing = locHandler.bearing
//        bearing = rawBearing.magneticHeading * toRadians as Double
//        startLat  = loc2D.latitude * toRadians as Double
//        startLong = loc2D.longitude * toRadians as Double
//    }
    
    
    func calculateForwardPoints () -> [CLLocationCoordinate2D] {
       
        initRadianValues()
        
        var pointArr2D = [CLLocationCoordinate2D]()
        pointArr2D.append(loc2D)
        
        var totalPoints = Double(numPoints)
        
        for pointNum in 0..<numPoints {
            var angleNum = Double(pointNum)
            bearing = bearing - sweepAngle/2 * toRadians
            
//            println(bearing)
//            println(angleNum)
//            println(sweepAngle/totalPoints)
//            println(toRadians)
//            println(angleNum * (sweepAngle/angleNum) * toRadians)
            
            bearing = bearing + angleNum * (sweepAngle/totalPoints) * toRadians
//            println(bearing)
            var endLat = asin( sin(startLat)*cos((distance/earthRad)) +  cos(startLat)*sin(distance/earthRad)*cos(bearing) )
            var endLong = startLong + atan2(sin(bearing)*sin(distance/earthRad)*cos(startLat)
                , cos(distance/earthRad)-sin(startLat)*sin(endLat) )
            
//            println("COMPUTED FORWARD POINT")
//            println(bearing)
//            println(startLat)
//            println(startLong)
//            println(endLat)
//            println(endLong)
//            
//            println(bearing*toDegrees)
//            println(startLat*toDegrees)
//            println(startLong*toDegrees)
//            println(endLat*toDegrees)
//            println(endLong*toDegrees)
            
            pointArr2D.append( CLLocationCoordinate2D(latitude: endLat * toDegrees, longitude: endLong * toDegrees) )
        }
//        pointArr2D.append(loc2D)
        return pointArr2D
    }
//    http://www.movable-type.co.uk/scripts/latlong.html
}
