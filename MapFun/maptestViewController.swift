//
//  maptestViewController.swift
//  MapFun
//
//  Created by NomiMalik on 17/10/2017.
//  Copyright © 2017 globia Technologies. All rights reserved.
//

import UIKit
import GooglePlaces
import GoogleMaps
import Alamofire
import SwiftyJSON
import GooglePlacePicker

class maptestViewController: UIViewController,CLLocationManagerDelegate{

    var placesClient: GMSPlacesClient!
    var locationManager = CLLocationManager()
    var currentLocation: CLLocation?
    var mapView: GMSMapView!
    var likelyPlaces: [GMSPlace] = []
    var placePicker: GMSPlacePicker!
    // The currently selected place.
    var selectedPlace: GMSPlace?

    var zoomLevel: Float = 15.0

    
    @IBOutlet weak var add: UILabel!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var viewmap: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()

        
        locationManager = CLLocationManager()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        locationManager.distanceFilter = 50
        locationManager.startUpdatingLocation()
        locationManager.delegate = self
        
        placesClient = GMSPlacesClient.shared()

        
        placesClient.currentPlace(callback: { (placeLikelihoodList, error) -> Void in
            if let error = error {
                print("Pick Place error: \(error.localizedDescription)")
                return
            }
            
            self.name.text = "No current place"
            self.add.text = ""
            
            if let placeLikelihoodList = placeLikelihoodList {
                let place = placeLikelihoodList.likelihoods.first?.place
                if let place = place {
                    
                    self.name.text = place.name
                    self.add.text = place.formattedAddress?.components(separatedBy: ", ")
                        .joined(separator: "\n")
                }
            }
        })

        let camera = GMSCameraPosition.camera(withLatitude: (locationManager.location?.coordinate.latitude)!,longitude: (locationManager.location?.coordinate.longitude)!,zoom: zoomLevel)
        
        
        
        
        
        mapView = GMSMapView.map(withFrame: view.bounds, camera: camera)
       // mapView.settings.myLocationButton = true
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        mapView.isMyLocationEnabled = true
        
        // Add the map to the view, hide it until we've got a location update.
        viewmap.addSubview(mapView)
       // viewmap.isHidden = true
        let source = CLLocationCoordinate2DMake((locationManager.location?.coordinate.latitude)!,(locationManager.location?.coordinate.longitude)!)
        let dest = CLLocationCoordinate2DMake(33.7017, 73.0228)
        let source1 = locationManager.location
        let dest1 = CLLocation(latitude: 33.7079, longitude: 73.0500)
        //getPolylineeRoute(from: source, to: dest)
        getplacesnearby(source: source1!,dest: dest1,distance: 1000,type: "restaurant")
        drawPath(startLocation: source1!, endLocation: dest1)
        addanotation(dest: dest1)
        
        
        
        
        // 1
        let center = CLLocationCoordinate2DMake((source1?.coordinate.latitude)!, (source1?.coordinate.longitude)!)
        let northEast = CLLocationCoordinate2DMake(center.latitude + 0.001, center.longitude + 0.001)
        let southWest = CLLocationCoordinate2DMake(center.latitude - 0.001, center.longitude - 0.001)
        let viewport = GMSCoordinateBounds(coordinate: northEast, coordinate: southWest)
        let config = GMSPlacePickerConfig(viewport: viewport)
        self.placePicker = GMSPlacePicker(config: config)

        // 2
        placePicker.pickPlace { (place: GMSPlace?, error: Error?) -> Void in

            if let error = error {
                print("Error occurred: \(error.localizedDescription)")
                return
            }
            // 3
            if let place = place {
                let coordinates = CLLocationCoordinate2DMake(place.coordinate.latitude, place.coordinate.longitude)
                let marker = GMSMarker(position: coordinates)
                marker.title = place.name
                marker.map = self.mapView
                self.mapView.animate(toLocation: coordinates)
            } else {
                print("No place was selected")
            }
        }

        
//        let marker = GMSMarker()
//        marker.position = CLLocationCoordinate2DMake(33.7079, 73.0500)
//        marker.groundAnchor = CGPoint(x: 0.5, y: 0.5)
//        marker.map = mapView
//
//        let path = GMSMutablePath()
//        path.add(CLLocationCoordinate2DMake((locationManager.location?.coordinate.latitude)!, (locationManager.location?.coordinate.longitude)!))
//        path.add(CLLocationCoordinate2DMake(33.7079, 73.0500))
//
//        let rectangle = GMSPolyline(path: path)
//        rectangle.strokeWidth = 5.0
//        rectangle.strokeColor = UIColor.red
//        rectangle.map = mapView
//
//        viewmap = mapView
//        fitAllMarkers(_path: path)
        
//        let camera = GMSCameraPosition.camera(withLatitude: -33.86, longitude: 151.20, zoom: 6.0)
//        let mapView = GMSMapView.map(withFrame: CGRect.zero, camera: camera)
//        viewmap = mapView
//
//
        // Creates a marker in the center of the map.
//        let marker = GMSMarker()
//        marker.position = CLLocationCoordinate2D(latitude:33.7079,longitude: 73.0500)
//        marker.title = "Centarus"
//        marker.snippet = "Pakistan"
//        marker.map = mapView
        
//        drawline()
        // Do any additional setup after loading the view.
    }

    
    
    
    func drawPath(startLocation: CLLocation, endLocation: CLLocation)
    {
        let origin = "\(startLocation.coordinate.latitude),\(startLocation.coordinate.longitude)"
        let destination = "\(endLocation.coordinate.latitude),\(endLocation.coordinate.longitude)"
        print(origin)
        print(destination)
        
        let url = "https://maps.googleapis.com/maps/api/directions/json?origin=\(origin)&destination=\(destination)&sensor=false&mode=driving"
        
        Alamofire.request(url).responseJSON { response in
            
            print(response.request as Any)  // original URL request
            print(response.response as Any) // HTTP URL response
            print(response.data as Any)     // server data
            print(response.result as Any)   // result of response serialization`
            
            let json = JSON(data: response.data!)
            let routes = json["routes"].arrayValue
            print(json["routes"])
            
            // print route using Polyline
            for route in routes
            {
                let routeOverviewPolyline = route["overview_polyline"].dictionary
                let points = routeOverviewPolyline?["points"]?.stringValue
                let path = GMSPath.init(fromEncodedPath: points!)
                let polyline = GMSPolyline.init(path: path)
                polyline.strokeWidth = 4
                polyline.strokeColor = UIColor.red
                polyline.map = self.mapView
            }
            
        }
    }
    
    func addanotation(dest: CLLocation)
    {
        let drop = GMSMarker()
        drop.position.latitude = dest.coordinate.latitude
        drop.position.longitude = dest.coordinate.longitude
        drop.map = mapView
        
    }
    
    func fitAllMarkers(_path: GMSMutablePath) {
        var bounds = GMSCoordinateBounds()
        for index in 1..._path.count() {
            bounds = bounds.includingCoordinate(_path.coordinate(at: index))
        }
        mapView.animate(with: GMSCameraUpdate.fit(bounds))
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func getplacesnearby(source:CLLocation, dest: CLLocation,distance:Int,type:String)
    {
        
        let latitude = "\(source.coordinate.latitude)"
        let longitute = "\(source.coordinate.longitude)"
        
        let apiKey = "AIzaSyCWIZD_tbTBJlU84nxhLXMKQAt7Ca9JuVI"
       // var googleURLString = NSString(format:"https://maps.googleapis.com/maps/api/place/search/json?location=%f,%f&radius=%@&types=%@&sensor=true&key=%@",latitude, longitute, distance, type, apiKey ) as String
            
           let url = URL(string: "https://maps.googleapis.com/maps/api/place/search/json?location=\(latitude),\(longitute)&radius=\(distance)&types=\(type)")
        print(url)
        let task = URLSession.shared.dataTask(with: url!) { (data, response, error) in
            
            DispatchQueue.main.async(execute: {
                
                if error != nil
                {
                    print("Error")
                }
                else
                {
                    if let content = data
                    {
                        do
                        {
                            let myJson = try JSONSerialization.jsonObject(with: content, options: JSONSerialization.ReadingOptions.mutableContainers) as! NSDictionary
                            
                            let asd = myJson.value(forKey: "results") as! NSMutableArray
                            print(asd)
                        }
                        catch
                        {
                            print(error.localizedDescription)
                        }

                    }
                }
            })
            
        }
        task.resume()
       
       
        }
       
    
    func getPolylineeRoute(from source: CLLocationCoordinate2D, to destination: CLLocationCoordinate2D){
        
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config)
        
        let url = URL(string: "http://maps.googleapis.com/maps/api/directions/json?origin=\(source.latitude),\(source.longitude)&destination=\(destination.latitude),\(destination.longitude)&sensor=false&mode=driving")!
        
        let task = session.dataTask(with: url, completionHandler: {
            (data, response, error) in
            if error != nil {
                print(error!.localizedDescription)
            }else{
                do {
                    if let json : [String:Any] = try JSONSerialization.jsonObject(with: data!, options: .allowFragments) as? [String: Any]{
                        print(json["routes"])
                        let routes = json["routes"] as? [Any]
                        let overview_polyline = routes?[0] as?[String:Any]
                        let polyString = overview_polyline?["points"] as?String
                        
                        //Call this method to draw path on map
                        self.showPath(polyStr: polyString!)
                    }
                    
                }catch{
                    print("error in JSONSerialization")
                }
            }
        })
        task.resume()
    }
    
    
    func getPolylineRoute(from source: CLLocationCoordinate2D, to destination: CLLocationCoordinate2D){
        
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config)
        
        let url = URL(string: "https://maps.googleapis.com/maps/api/directions/json?origin=\(source.latitude),\(source.longitude)&destination=\(destination.latitude),\(destination.longitude)&sensor=false&mode=driving")!
        
        let task = session.dataTask(with: url, completionHandler: {
            (data, response, error) in
            if error != nil {
                print(error!.localizedDescription)
               // self.activityIndicator.stopAnimating()
            }
            else {
                do {
                    if let json : [String:Any] = try JSONSerialization.jsonObject(with: data!, options: .allowFragments) as? [String: Any]{
                        
                        guard let routes = json["routes"] as? NSArray else {
                            DispatchQueue.main.async {
                              //  self.activityIndicator.stopAnimating()
                            }
                            return
                        }
                        print(data)
                        if (routes.count > 0) {
                            let overview_polyline = routes[0] as? NSDictionary
                            let dictPolyline = overview_polyline?["overview_polyline"] as? NSDictionary
                            
                            let points = dictPolyline?.object(forKey: "points") as? String
                            
                            self.showPath(polyStr: points!)
                            
                            DispatchQueue.main.async {
                              //  self.activityIndicator.stopAnimating()
                                
                                let bounds = GMSCoordinateBounds(coordinate: source, coordinate: destination)
                                let update = GMSCameraUpdate.fit(bounds, with: UIEdgeInsetsMake(170, 30, 30, 30))
                                self.mapView!.moveCamera(update)
                            }
                        }
                        else {
                            DispatchQueue.main.async {
                               // self.activityIndicator.stopAnimating()
                            }
                        }
                    }
                }
                catch {
                    print("error in JSONSerialization")
                    DispatchQueue.main.async {
                       // self.activityIndicator.stopAnimating()
                    }
                }
            }
        })
        task.resume()
    }
    
    
    func showPath(polyStr :String){
        let path = GMSPath(fromEncodedPath: polyStr)
        let polyline = GMSPolyline(path: path)
        polyline.strokeWidth = 3.0
        polyline.strokeColor = UIColor.red
        polyline.map = mapView // Your map view
    }
    

    func drawline()
    {
       // let cameraPositionCoordinates = CLLocationCoordinate2D(latitude: (locationManager.location?.coordinate.latitude)!, longitude: (locationManager.location?.coordinate.longitude)!)
       // let cameraPosition = GMSCameraPosition.camera(withTarget: cameraPositionCoordinates, zoom: 12)
        
        //let mapView = GMSMapView.map(withFrame: CGRect.zero, camera: cameraPosition)
        //mapView.isMyLocationEnabled = true
        
        let marker = GMSMarker()
        marker.position = CLLocationCoordinate2DMake(33.7079, 73.0500)
        marker.groundAnchor = CGPoint(x: 0.5, y: 0.5)
        marker.map = mapView
        
        let path = GMSMutablePath()
        path.add(CLLocationCoordinate2DMake((locationManager.location?.coordinate.latitude)!, (locationManager.location?.coordinate.longitude)!))
        path.add(CLLocationCoordinate2DMake(33.7079, 73.0500))
        
        let rectangle = GMSPolyline(path: path)
        rectangle.strokeWidth = 5.0
        rectangle.map = mapView
        
        viewmap = mapView
    }
    
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .restricted:
            print("Location access was restricted.")
        case .denied:
            print("User denied access to location.")
            // Display the map using the default location.
            mapView.isHidden = false
        case .notDetermined:
            print("Location status not determined.")
        case .authorizedAlways: fallthrough
        case .authorizedWhenInUse:
            print("Location status is OK.")
        }
    }
    
    
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        let loc = locations[0]
        print("Latitude : \(loc.coordinate.latitude) and Longitude : \(loc.coordinate.latitude)")
        print("Speed: \(loc.speed)")
        print("Location altitude: \(loc.altitude)")
        CLGeocoder().reverseGeocodeLocation(loc) { (placemarks , error ) in
            if error != nil
            {
                print(error!)
            }
            else
            {
                if let placemark = placemarks?[0]
                {
                   // var address = " "
                    if placemark.subThoroughfare != nil
                    {
                         print(placemark.country!)
                         print(placemark.subThoroughfare!)
                    }
                }
            }
            
        }
        
        let location: CLLocation = locations.last!
        print("Location: \(location)")
        
        let camera = GMSCameraPosition.camera(withLatitude: location.coordinate.latitude,
                                              longitude: location.coordinate.longitude,
                                              zoom: zoomLevel)
        
        if mapView.isHidden {
            mapView.isHidden = false
            mapView.camera = camera
        } else {
            mapView.animate(to: camera)
        }
        
        listLikelyPlaces()
    }
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        locationManager.stopUpdatingLocation()
        print("Error: \(error)")
    }
    
    
    func listLikelyPlaces() {
        // Clean up from previous sessions.
        likelyPlaces.removeAll()
        
        placesClient.currentPlace(callback: { (placeLikelihoods, error) -> Void in
            if let error = error {
                // TODO: Handle the error.
                print("Current Place error: \(error.localizedDescription)")
                return
            }
            
            // Get likely places and add to the list.
            if let likelihoodList = placeLikelihoods {
                for likelihood in likelihoodList.likelihoods {
                    let place = likelihood.place
                    self.likelyPlaces.append(place)
                }
            }
        })
    }
    
    
    

    
    func locationManager(manager: CLLocationManager,didFailWithError error: NSError){
        
        print("An error occurred while tracking location changes : \(error.description)")
    }

    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}


