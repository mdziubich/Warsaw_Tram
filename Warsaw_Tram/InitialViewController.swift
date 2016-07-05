//
//  ViewController.swift
//  Warsaw_Tram
//
//  Created by Małgorzata Dziubich on 23/06/16.
//  Copyright © 2016 Małgorzata Dziubich. All rights reserved.
//

import UIKit

class InitialViewController: UIViewController, AlertHelperProtocol {

    @IBOutlet var pickerView: UIPickerView!
    @IBOutlet var lowFloorTramSwitch: UISwitch!
    
    let tramViewModel = TramViewModel()
    
    var allActiveTrams = [Tram]()
    var tramsNumberList = [Int]()
    var lowFloorTramsNumberList = [Int]()
    var tramNumberToDisplayOnMap = String()
    var showAllTrams: Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()
        lowFloorTramSwitch.on = false
        fetchTramsData()
    }
    
    @IBAction func showTramsButton(sender: AnyObject) {
        if tramNumberToDisplayOnMap == "" {
            showError(message: "You need to choose a tram!")
        } else {
            self.performSegueWithIdentifier("ShowMap", sender: self)
        }
    }
    
    @IBAction func showAllTramsButton(sender: AnyObject) {
        showAllTrams = true
        self.performSegueWithIdentifier("ShowMap", sender: self)
    }
    
    @IBAction func switchValueDidChange(sender: AnyObject) {
        pickerView.reloadAllComponents()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let viewController = segue.destinationViewController as! MapViewController
        viewController.allActiveTrams = allActiveTrams
        viewController.tramNumberToDisplayOnMap = tramNumberToDisplayOnMap
        viewController.lowFloorFilter = lowFloorTramSwitch.on
        viewController.showAllTrams = showAllTrams
    }
    
    private func fetchTramsData() {
        tramViewModel.getTramsData({ (trams) in
            for tram in trams where tram.status == "RUNNING" {
                self.allActiveTrams.append(tram)
            }
            self.sortTramsNumbers()
            self.pickerView.reloadAllComponents()
        }, failure: { (error) in
            dispatch_async(dispatch_get_main_queue(), {
                self.showError(message: error)
            })
        })
    }
    
    //  Prepare sorted list of all active trams and active low floor to display in UIPickerView
    private func sortTramsNumbers() {
        var tramNumbers = [Int]()
        var lowFloorTrams = [Int]()
        
        for tram in allActiveTrams {
            if let number = Int(tram.number.stringByReplacingOccurrencesOfString(" ", withString: "")) {
                if tram.lowFloor {
                    lowFloorTrams.append(number)
                    tramNumbers.append(number)
                } else {
                    tramNumbers.append(number)
                }
            }
        }
        tramsNumberList = tramNumbers.unique().sort(){$0 < $1}
        lowFloorTramsNumberList = lowFloorTrams.unique().sort(){$0 < $1}
    }
    
    private func showError(message error: String) {
        NSLog(error)
        
        let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default) {
            UIAlertAction in
        }
        showAlert("Error", message: error, okAction: okAction)
    }
}

// MARK: UIPickerViewDelegate + UIPickerViewDataSource
extension InitialViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return lowFloorTramSwitch.on ? lowFloorTramsNumberList.count : tramsNumberList.count
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return lowFloorTramSwitch.on ? String(lowFloorTramsNumberList[row]) : String(tramsNumberList[row])
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        tramNumberToDisplayOnMap = lowFloorTramSwitch.on ? String(lowFloorTramsNumberList[row]) : String(tramsNumberList[row])
    }
}
