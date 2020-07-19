//
//  RegisterLocationVC.swift
//  famouschat
//
//  Created by T-Tech Solutions LLC on 14/11/2018.
//  Copyright © 2018 T-Tech Solutions LLC. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class RegisterLocationVC: UIViewController,MKMapViewDelegate, CLLocationManagerDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var myLocationView: UIView!
    @IBOutlet weak var logOutView: UIView!
    @IBOutlet weak var mapModeBtn: UIButton!
    @IBOutlet weak var mapModeView: UIView!
    
    let manager = CLLocationManager()
    let regionRadius: CLLocationDistance = 1000
    var currentLocation: CLLocation?
    
    var mapLatitude: Double = 0.0
    var mapLongitude: Double = 0.0
    var address: String = ""
    
    
    var map_status = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        init_UI()
        
    }
    
    func init_UI()
    {
        self.navigationController?.isNavigationBarHidden = true
        
        self.mapView.delegate =  self
        self.mapView.showsScale = true
        self.mapView.showsPointsOfInterest = true
        self.mapView.showsUserLocation = true
        mapView.mapType = MKMapType.satellite
        
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.requestWhenInUseAuthorization()
        manager.startUpdatingLocation()
        
        if(CLLocationManager.locationServicesEnabled())
        {
            self.manager.delegate = self
            self.manager.desiredAccuracy = kCLLocationAccuracyBest
            self.manager.startUpdatingLocation()
        }
        
        
        myLocationView.layer.cornerRadius = 14
        logOutView.layer.cornerRadius = 14
        mapModeView.layer.cornerRadius = 14
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        if !map_status
        {
            
            mapModeBtn.setImage(#imageLiteral(resourceName: "map_sat.jpg"), for: .normal)
            
            mapView.mapType = MKMapType.standard
        }
        else
        {
            
            mapModeBtn.setImage(#imageLiteral(resourceName: "map_nor.png"), for: .normal)
            mapView.mapType = MKMapType.satellite
        }
        
    }
    
    @IBAction func myLocationAction(_ sender: Any) {
        
        centerMapOnLocation(location: currentLocation!)
    }
    
    @IBAction func logOutAction(_ sender: Any) {
        
        
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func mapModeAction(_ sender: Any) {
        
        if map_status
        {
            map_status = false
        }
        else
        {
            map_status = true
        }
        self.viewWillAppear(true)
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
}

extension RegisterLocationVC
{
    
    func centerMapOnLocation(location: CLLocation) {
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate,
                                                                  regionRadius, regionRadius)
        mapView.setRegion(coordinateRegion, animated: true)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        currentLocation = locations[0]
        
        centerMapOnLocation(location: currentLocation!)
        
    }
    
    
    
    func mapView(_ mapView: MKMapView,
                 regionDidChangeAnimated animated: Bool) {
        
        
        mapLatitude = mapView.centerCoordinate.latitude
        mapLongitude = mapView.centerCoordinate.longitude
        
        let lastLocation = CLLocation(latitude: mapLatitude, longitude: mapLongitude)
        let geocoder = CLGeocoder()
        
        
        geocoder.reverseGeocodeLocation(lastLocation,
                                        completionHandler: { (placemarks, error) in
                                            if error == nil {
                                                let firstLocation = placemarks?[0]
                                                let str = String(describing: firstLocation)
                                                //completionHandler(firstLocation)
                                                let array = String(describing: str.characters.split{$0 == "@"}.map(String.init)[0])
                                                var array1 = array.characters.split{$0 == ","}.map(String.init)
                                                array1.remove(at: 0)
                                                
                                                var tempAddress = String()
                                                for i in 0..<array1.count - 1
                                                {
                                                    tempAddress += "\(array1[i]), "
                                                }
                                                tempAddress += "\(array1[array1.count - 1])"
                                                
                                                self.address = tempAddress
                                                
                                            }
        })
        
    }
}
