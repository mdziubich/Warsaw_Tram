//
//  MapViewController.swift
//  Warsaw_Tram
//
//  Created by Małgorzata Dziubich on 23/06/16.
//  Copyright © 2016 Małgorzata Dziubich. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class MapViewController: UIViewController, AlertHelperProtocol {

    @IBOutlet var map: MKMapView!
    
    var locationManager = CLLocationManager()
    var userLocationDefined = false
    var userLocation: CLLocationCoordinate2D?
    let tramViewModel = TramViewModel()
    var allActiveTrams = [Tram]()
    var tramNumberToDisplayOnMap = String()
    var lowFloorFilter: Bool = false
    var showAllTrams: Bool = false
    
    let resourceId = "id=c7238cfe-8b1f-4c38-bb4a-de386db7e776"
    let warsawTramsApiKey = "apikey=060b903c-b0c3-427e-934d-9e4a81a61969"
    let mapLatDelta: CLLocationDegrees = 0.05
    let mapLonDelta: CLLocationDegrees = 0.05
    
    override func viewDidLoad() {
        setupMap()
        setupLocationManager()
        super.viewDidLoad()
    }
    
    @IBAction func showCurrentLocation(sender: AnyObject) {
        showUserCurrentLocation()
    }
    
    private func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    private func setupMap() {
        navigationController?.navigationBar.backgroundColor = UIColor.orangeColor()
        map.showsScale = true
    }
    
    private func displayTramsOnMap() {
        let priority = DISPATCH_QUEUE_PRIORITY_DEFAULT
        dispatch_async(dispatch_get_global_queue(priority, 0)) {
            for tram in self.allActiveTrams {
                if self.showAllTrams {
                    self.addTramAnnotation(tram)
                } else if self.lowFloorFilter && tram.lowFloor && tram.number.stringByReplacingOccurrencesOfString(" ", withString: "") == self.tramNumberToDisplayOnMap {
                    self.addTramAnnotation(tram)
                } else if tram.number.stringByReplacingOccurrencesOfString(" ", withString: "") == self.tramNumberToDisplayOnMap {
                    self.addTramAnnotation(tram)
                }
            }
            
            dispatch_async(dispatch_get_main_queue(), {
                self.showUserCurrentLocation()
            })
        }
    }
    
    private func addTramAnnotation(tram: Tram) {
        let location:CLLocationCoordinate2D = CLLocationCoordinate2DMake(tram.latitude, tram.longitude)
        let annotation = MKPointAnnotation()
        annotation.coordinate = location
        annotation.title = tram.number
        if tram.lowFloor == true {
            annotation.subtitle = "Low floor tram"
        }
        map.addAnnotation(annotation)
    }
    
    // Zoom map to current location
    private func showUserCurrentLocation() {
        if let location = self.userLocation {
            let span = MKCoordinateSpanMake(mapLatDelta, mapLonDelta)
            let region = MKCoordinateRegion(center: location, span: span)
            self.map.setRegion(region, animated: true)
        }
    }
}

// MARK: CLLocationManagerDelegate
extension MapViewController: CLLocationManagerDelegate {
    
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        //  Check access for user location
        if status == .AuthorizedWhenInUse {
            locationManager.requestLocation()
            displayTramsOnMap()
            showUserCurrentLocation()
        } else {
            showSettingsAlert()
        }
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            self.userLocation = location.coordinate
            if !userLocationDefined {
                userLocationDefined = true
            }
        }
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        NSLog(error.localizedDescription)
    }
    
    private func showSettingsAlert() {
        // Create the actions buttons for settings alert
        let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default) {
            UIAlertAction in
            UIApplication.sharedApplication().openURL(NSURL(string: UIApplicationOpenSettingsURLString)!)
            NSLog("OK Pressed")
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel) {
            UIAlertAction in
            NSLog("Cancel Pressed")
            self.performSegueWithIdentifier("ShowMainDesktop", sender: nil)
        }
        
        showAlert("Error", message: "No access to location services. Do you want to change your settings now?", okAction: okAction, cancelAction: cancelAction)
    }
}
