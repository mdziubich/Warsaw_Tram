//
//  TramViewModel.swift
//  Warsaw_Tram
//
//  Created by Małgorzata Dziubich on 28/06/16.
//  Copyright © 2016 Małgorzata Dziubich. All rights reserved.
//

import UIKit

class TramViewModel {
    
    let resourceId = "id=c7238cfe-8b1f-4c38-bb4a-de386db7e776"
    let warsawTramsApiKey = "apikey=060b903c-b0c3-427e-934d-9e4a81a61969"
    var session = NSURLSession.self
    
    func fetchTramsNumbers(success: (trams: [Int], lowFloorTrams: [Int]) -> Void, failure: String -> Void) {
        getTramsData({ (trams) in
            var tramNumbers = [Int]()
            var lowFloorTrams = [Int]()
            
            for tram in trams where tram.status == "RUNNING" {
                if let number = Int(tram.number) {
                    if tram.lowFloor {
                        lowFloorTrams.append(number)
                        tramNumbers.append(number)
                    } else {
                        tramNumbers.append(number)
                    }
                }
            }
            let tramsNumberList = tramNumbers.unique().sort(){$0 < $1}
            let lowFloorTramsNumberList = lowFloorTrams.unique().sort(){$0 < $1}
            
            success(trams: tramsNumberList, lowFloorTrams: lowFloorTramsNumberList)
            
        }, failure: { (error) in
                failure(error)
        })
    }
    
    func fetchTramsForMap(tramsParameters: DisplayedTramsData, success: [Tram] -> Void, failure: String -> Void) {
        getTramsData({ (trams) in
            var finalTrams = [Tram]()
            for tram in trams where tram.status == "RUNNING" {
                if tramsParameters.showAllTrams {
                    finalTrams.append(tram)
                } else if tramsParameters.lowFloorFilter && tram.lowFloor && tram.number == tramsParameters.tramNumber {
                    finalTrams.append(tram)
                } else if tram.number == tramsParameters.tramNumber {
                    finalTrams.append(tram)
                }
            }
            success(finalTrams)
            
        }, failure: { (error) in
            failure(error)
        })
    }
    
    private func getTramsData(success: [Tram] -> Void, failure: String -> Void) {
        
        var trams = [Tram]()
        let stringURL = "https://api.um.warszawa.pl/api/action/wsstore_get?\(resourceId)&\(warsawTramsApiKey)"
        let url = NSURL(string: stringURL)!
        
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "GET"
        
        let task = session.sharedSession().dataTaskWithRequest(request) { data, response, error in
            
            guard let taskError = error?.localizedDescription else {
                do {
                    guard let taskData = data,
                        let jsonResult = try NSJSONSerialization.JSONObjectWithData(taskData, options: NSJSONReadingOptions.MutableContainers) as? NSDictionary,
                        let result: Array = jsonResult["result"] as? Array<AnyObject> else {
                            return failure("No results")
                    }
                    
                    for tram in result {
                        if let singleTram = tram as? [String : AnyObject] {
                            trams.append(Tram(tram: singleTram)!)
                        }
                    }
                } catch let error as NSError {
                    return failure(error.localizedDescription)
                }
                return success(trams)
            }
            failure(taskError)
        }
        task.resume()
    }
    
    func fetchTramsNumbers(success: (trams: [Int], lowFloorTrams: [Int]) -> Void, failure: String -> Void) {
        getTramsData({ (trams) in
            var tramNumbers = [Int]()
            var lowFloorTrams = [Int]()
            
            for tram in trams where tram.status == "RUNNING" {
                if let number = Int(tram.number) {
                    if tram.lowFloor {
                        lowFloorTrams.append(number)
                        tramNumbers.append(number)
                    } else {
                        tramNumbers.append(number)
                    }
                }
            }
            let tramsNumberList = tramNumbers.unique().sort(){$0 < $1}
            let lowFloorTramsNumberList = lowFloorTrams.unique().sort(){$0 < $1}
            
            success(trams: tramsNumberList, lowFloorTrams: lowFloorTramsNumberList)
            
        }, failure: { (error) in
                failure(error)
        })
    }
    
    func fetchTramsForMap(tramsParameters: DisplayedTramsData, success: [Tram] -> Void, failure: String -> Void) {
        getTramsData({ (trams) in
            var finalTrams = [Tram]()
            for tram in trams where tram.status == "RUNNING" {
                if tramsParameters.showAllTrams {
                    finalTrams.append(tram)
                } else if tramsParameters.lowFloorFilter && tram.lowFloor && tram.number == tramsParameters.tramNumber {
                    finalTrams.append(tram)
                } else if tram.number == tramsParameters.tramNumber {
                    finalTrams.append(tram)
                }
            }
            success(finalTrams)
            
        }, failure: { (error) in
            failure(error)
        })
    }
}
