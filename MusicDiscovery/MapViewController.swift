import UIKit

class MapViewController: UIViewController, MapUpdateProtocol, LocationNotificationProtocol, LocationAlertProtocol {
    
    let locHandler = LocationHandler.sharedInstance
    
    @IBOutlet weak var mapView: GMSMapView!
    
    var mapSetup: Bool = false
    
    let calculator = MapCalculator()
    
    var currentMapType: GMSMapViewType = kGMSTypeNormal
    
    var mapTimer: NSTimer!
    
    var conicPolygon = GMSPolygon()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(animated: Bool) {
        mapView.myLocationEnabled = true
        mapView.settings.myLocationButton = true
        
        locHandler.locationHandlerDelegate = self
        locHandler.mapUpdateDelgate = self
        
        notifyLocationHandler()
        
        mapTimerInit()
    }
    
    func notifyLocationHandler () -> Void {
        locHandler.mapViewExists = true
    }
    
    func checkMapExistence() -> Bool {
        if mapView != nil {
            return true
        }
        return false
    }
    
    
    func mapTimerInit() -> Void {
        self.mapTimer = NSTimer(timeInterval: 0.1, target: self, selector: Selector("mapTimerDidFire"), userInfo: nil, repeats: true)
        NSRunLoop.currentRunLoop().addTimer(self.mapTimer, forMode: NSRunLoopCommonModes)
    }
    
    func mapTimerDidFire() -> Void {
        println("map timer fired")
        if !self.mapSetup {
            setMapLocation()
        } else {
            mapTimerKill()
        }
    }
    
    func mapTimerKill() -> Void {
        self.mapTimer.invalidate()
    }
    
    func updateMapViewToCamera () -> Void {
        println("Updating map view")
        if locHandler.location2D != nil && locHandler.bearing != nil {
            println("************Bearing is not nil***************")
            var magneticBearing = locHandler.bearing.magneticHeading
            var location2D = locHandler.location2D
            var mapZoom = self.mapView.camera.zoom
            mapView.camera = GMSCameraPosition(target: location2D, zoom: mapZoom, bearing: magneticBearing, viewingAngle: 0)
//                mapView.mapType = currentMapType
            drawCone()
        }
    }
    
    func updateMapViewToBearing () -> Void {
        println("Updating map view")
        if locHandler.bearing != nil {
            println("************Bearing is not nil***************")
            var magneticBearing = locHandler.bearing.magneticHeading
            self.mapView.animateToBearing(magneticBearing)
            drawCone()
        }
    }
    
    func updateMapViewTarget() -> Void {
        var cameraTargetUpdate = GMSCameraUpdate.setTarget(locHandler.location2D)
        self.mapView.animateWithCameraUpdate(cameraTargetUpdate)
        drawCone()
    }
    
    func setMapLocation () -> Void {
        
        if mapView != nil {
            if locHandler.location2D != nil {
                mapView.camera = GMSCameraPosition(target: locHandler.location2D, zoom: 50, bearing: 0, viewingAngle: 0)
                mapView.mapType = currentMapType
                mapView.settings.scrollGestures = false
    //            drawPolygon()
    //            calculator.calculatePoint()
                //stop the timer now that the map is setup
                mapTimerKill()
                self.mapSetup = true
            }
        }
    }
    
    func getAndPushAlert (locationAlert: UIAlertController) -> Void {
        self.presentViewController(locationAlert, animated: true, completion: nil)
    }
    
    func drawCone() -> Void {
        
        var points2D:[CLLocationCoordinate2D] = calculator.calculateForwardPoints()
        
        println(points2D)
        
        var conicPath = GMSMutablePath()
        for point in points2D {
            println(point.latitude)
            println(point.longitude)
            conicPath.addCoordinate(point)
        }
        
        conicPolygon.map = nil
        conicPolygon = GMSPolygon(path: conicPath)
        conicPolygon.fillColor = UIColor(red:0.25, green:0, blue:0, alpha:0.05)
        conicPolygon.strokeColor = UIColor.blackColor()
        conicPolygon.strokeWidth = 2
        conicPolygon.map = mapView
    }
    
    //this is only a test function
    func drawLine () -> Void {
        var path = GMSMutablePath()
        path.addCoordinate(locHandler.location2D)
    //    path.addCoordinate(calculator.calculateForwardPoint())
        
        var line = GMSPolyline(path: path)
        line.strokeColor = UIColor.blackColor()
        line.strokeWidth = 2
        line.map = self.mapView
    }
    
    //This is only a test function
    func drawPolygon () -> Void {
        // Create a rectangular path
        var rect = GMSMutablePath()
        rect.addCoordinate(CLLocationCoordinate2DMake(37.36, -122.0))
        rect.addCoordinate(CLLocationCoordinate2DMake(37.45, -122.0))
        rect.addCoordinate(CLLocationCoordinate2DMake(37.45, -122.2))
        rect.addCoordinate(CLLocationCoordinate2DMake(37.36, -122.2))
        
        // Create the polygon, and assign it to the map.
        var polygon = GMSPolygon(path: rect)
        polygon.fillColor = UIColor(red:0.25, green:0, blue:0, alpha:0.05)
        polygon.strokeColor = UIColor.blackColor()
        polygon.strokeWidth = 2
        polygon.map = mapView
    }
    


    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {

    }

}

