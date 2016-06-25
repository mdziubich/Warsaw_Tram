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

class MapViewController: UIViewController {

    @IBOutlet var map: MKMapView!
    
    var locationManager = CLLocationManager()
    var alertHelper: AlertHelper?
    var userLocationDefined: Bool = false
    var userLocation: CLLocationCoordinate2D?
    
    let resourceId = "id=c7238cfe-8b1f-4c38-bb4a-de386db7e776"
    let warsawTramsApiKey = "apikey=060b903c-b0c3-427e-934d-9e4a81a61969"
    let mapLatDelta: CLLocationDegrees = 0.05
    let mapLonDelta: CLLocationDegrees = 0.05
    
    override func viewDidLoad() {
        alertHelper = AlertHelper()
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
    
    private func fetchTramsData() {
        let stringURL : NSString = "https://api.um.warszawa.pl/api/action/wsstore_get?\(resourceId)&\(warsawTramsApiKey)"
        let url : NSURL = NSURL(string: stringURL as String)!
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "GET"
        
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request) { data, response, error in
            if error != nil {
                self.goToMainDesktop(errorMessage: error!.localizedDescription)
            } else if data != nil {
                guard let jsonResult = (try! NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers)) as? NSDictionary,
                    let result: NSArray = jsonResult["result"] as? NSArray else {
                        return self.goToMainDesktop(errorMessage: "Brak wyników")
                }
                
                for tram in result {
                    if tram["Status"] as? String == "RUNNING" {
                        if let line = tram["FirstLine"] as? String,
                            let lat = tram["Lat"] as? CLLocationDegrees,
                            let lon = tram["Lon"] as? CLLocationDegrees,
                            let lowFloor = tram["LowFloor"] as? Bool {
                                dispatch_async(dispatch_get_main_queue(), { 
                                    self.addTramAnnotation(line, lat: lat, lon: lon, lowFloor: lowFloor)
                                })
                        }
                    }
                }
            } else {
                self.goToMainDesktop(errorMessage: "Brak aktywnych tramwaji")
            }
        }
        task.resume()
    }
    
    private func addTramAnnotation(lineNumber: String, lat: CLLocationDegrees, lon: CLLocationDegrees, lowFloor: Bool) {
        let location:CLLocationCoordinate2D = CLLocationCoordinate2DMake(lat, lon)
        let annotation = MKPointAnnotation()
        annotation.coordinate = location
        annotation.title = lineNumber
        annotation.subtitle = lowFloor ? "Tramwaj niskopodłogowy" : nil
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
    
    private func goToMainDesktop(errorMessage error: String) {
        print("error: \(error)")
        
        let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default) {
            UIAlertAction in
            self.performSegueWithIdentifier("showMainDesktop", sender: nil)
        }
        
        alertHelper?.showAlert("Błąd", message: error, okAction: okAction, presentingViewController: self)
    }
}

// MARK: CLLocationManagerDelegate
extension MapViewController: CLLocationManagerDelegate {
    
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        //  Check access for user location
        if status == .AuthorizedWhenInUse {
            locationManager.requestLocation()
            fetchTramsData()
        } else {
            showSettingsAlert()
        }
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            self.userLocation = location.coordinate
            if !userLocationDefined {
                showUserCurrentLocation()
                userLocationDefined = true
            }
        }
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        print("error:: \(error)")
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
            self.performSegueWithIdentifier("showMainDesktop", sender: nil)
        }
        
        alertHelper?.showAlert("Błąd", message: "Brak dostępu do usługi lokalizacji. Czy chcesz zmienić ustawienia teraz?", okAction: okAction, cancelAction: cancelAction, presentingViewController: self)
    }
}
