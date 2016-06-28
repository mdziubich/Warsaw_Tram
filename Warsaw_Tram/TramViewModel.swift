//
//  TramViewModel.swift
//  Warsaw_Tram
//
//  Created by Małgorzata Dziubich on 28/06/16.
//  Copyright © 2016 Małgorzata Dziubich. All rights reserved.
//

import UIKit

protocol TramViewModelProtocol {
    
    func getTramsData(success: [Tram] -> Void, failure: String -> Void) -> Void
}

class TramViewModel: TramViewModelProtocol {
    
    let resourceId = "id=c7238cfe-8b1f-4c38-bb4a-de386db7e776"
    let warsawTramsApiKey = "apikey=060b903c-b0c3-427e-934d-9e4a81a61969"

    func getTramsData(success: [Tram] -> Void, failure: String -> Void) -> Void {
        var trams = [Tram]()
        let stringURL = "https://api.um.warszawa.pl/api/action/wsstore_get?\(resourceId)&\(warsawTramsApiKey)"
        let url = NSURL(string: stringURL)!
        
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "GET"
        
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request) { data, response, error in
            
            if error != nil {
                failure(error!.localizedDescription)
            } else if data != nil {
                guard let jsonResult = (try! NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers)) as? NSDictionary,
                    let result: NSArray = jsonResult["result"] as? NSArray else {
                        return failure("No results")
                }
                
                for tram in result {
                    if let singleTram = tram as? [String : AnyObject] {
                        trams.append(Tram(tram: singleTram)!)
                    }
                }
                success(trams)
            }
        }
        task.resume()
    }
}
