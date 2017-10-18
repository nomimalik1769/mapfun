//
//  ViewController.swift
//  MapFun
//
//  Created by Admin on 17/10/2017.
//  Copyright © 2017 globia Technologies. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class ViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {
// AIzaSyBx4JtZfiOsWZWowGaMuQsH2P566pwQFow 
    @IBOutlet weak var mapkit: MKMapView!
    let manager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
      // manager.delegate = self
      //  manager.desiredAccuracy = kCLLocationAccuracyBest
        
      //  manager.startUpdatingLocation()
        self.mapkit.showsUserLocation = true
        
        self.mapkit.delegate = self
        manager.requestWhenInUseAuthorization()
        manager.requestAlwaysAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            
            
            manager.delegate = self
            manager.desiredAccuracy = kCLLocationAccuracyBest
            
            manager.startUpdatingLocation()
        }
        
        
        let myloc =  manager.location?.coordinate           //CLLocationCoordinate2DMake(36.8485, 174.7633)   //
        
        let mmdes = CLLocationCoordinate2DMake(33.6818, 72.9899)
       
        
       // let region:MKCoordinateRegion = MKCoordinateRegionMake(myloc, span)
        //mapkit.setRegion(region, animated: true)
        
        
        
        let sourceplacemarker = MKPlacemark(coordinate: myloc!)
        let desplacemarker = MKPlacemark(coordinate: mmdes)
        
        let sourceItem = MKMapItem(placemark: sourceplacemarker)
        let desItem = MKMapItem(placemark: desplacemarker)
        
        let direction = MKDirectionsRequest()
        direction.source = sourceItem
        
        direction.destination = desItem
        direction.requestsAlternateRoutes = true
        direction.transportType = .automobile
        
        let dir = MKDirections(request: direction)
        dir.calculate(completionHandler:  { (response, error) in
            guard let response = response else{
                if let error = error {
                    print(error)
                }
                return
            }
            
            if response.routes.count > 0
            {
            
            let route = response.routes[0]
            self.mapkit.add(route.polyline, level: .aboveRoads)
            
            let rect = route.polyline.boundingMapRect
            self.mapkit.setRegion(MKCoordinateRegionForMapRect(rect), animated: true)
               // self.mapkit.showsUserLocation = true
            }
            
        })

        
       
        
        
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
       // let location = locations[0]
        //let span:MKCoordinateSpan = MKCoordinateSpanMake(0.01, 0.01)
        
        
        
       
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let render = MKPolylineRenderer(overlay: overlay)
        render.strokeColor = UIColor.blue
        render.lineWidth = 5.0
        return render
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

