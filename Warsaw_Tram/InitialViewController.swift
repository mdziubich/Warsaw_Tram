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
    var tramsNumberList = [Int]()
    var lowFloorTramsNumberList = [Int]()
    var tramNumberToDisplayOnMap = ""
    var showAllTrams = false

    override func viewDidLoad() {
        super.viewDidLoad()
        lowFloorTramSwitch.on = false
        fetchTramsData()
    }
    
    @IBAction func showTramsButton(sender: AnyObject) {
        if tramNumberToDisplayOnMap == "" {
            showError(message: "You need to choose a tram!")
        } else {
            performSegueWithIdentifier("ShowMap", sender: self)
        }
    }
    
    @IBAction func showAllTramsButton(sender: AnyObject) {
        showAllTrams = true
        performSegueWithIdentifier("ShowMap", sender: self)
    }
    
    @IBAction func switchValueDidChange(sender: AnyObject) {
        pickerView.reloadAllComponents()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let viewController = segue.destinationViewController as! MapViewController
        let trams = DisplayedTramsData(tramNumberToDisplayOnMap: tramNumberToDisplayOnMap, showAllTrams: showAllTrams, lowFloorFilter: lowFloorTramSwitch.on)
        viewController.trams = trams
    }
    
    private func fetchTramsData() {
        tramViewModel.fetchTramsNumbers({ [weak self] (trams, lowFloorTrams) in
            self?.tramsNumberList = trams
            self?.lowFloorTramsNumberList = lowFloorTrams
            if let firstTram = self?.tramsNumberList[0] {
                self?.tramNumberToDisplayOnMap = String(firstTram)
            }
            dispatch_async(dispatch_get_main_queue(), {
                self?.pickerView.reloadAllComponents()
                self?.pickerView.selectRow(0, inComponent: 0, animated: true)
            })

        }, failure: { (error) in
            dispatch_async(dispatch_get_main_queue(), {
                self.showError(message: error)
            })
        })
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
