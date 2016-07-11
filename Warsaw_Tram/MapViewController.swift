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
    var userLocation: CLLocationCoordinate2D?
    let tramViewModel = TramViewModel()
    var trams: DisplayedTramsData?
    
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
        if let tramsParameters = trams {
            tramViewModel.fetchTramsForMap(tramsParameters, success: { [weak self] (trams) in
                for tram in trams {
                    self?.addTramAnnotation(tram)
                }
                self?.showUserCurrentLocation()
            }, failure: { (error) in
                dispatch_async(dispatch_get_main_queue(), {
                    self.showError(message: error)
                })
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
            let mapLatDelta: CLLocationDegrees = 0.05
            let mapLonDelta: CLLocationDegrees = 0.05
            
            let span = MKCoordinateSpanMake(mapLatDelta, mapLonDelta)
            let region = MKCoordinateRegion(center: location, span: span)
            self.map.setRegion(region, animated: true)
        }
    }
    
    private func showError(message error: String) {
        NSLog(error)
        
        let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default) {
            UIAlertAction in
            self.performSegueWithIdentifier("ShowMainDesktop", sender: self)
        }
        showAlert("Error", message: error, okAction: okAction)
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
