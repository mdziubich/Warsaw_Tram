//
//  StubNSURLSession.swift
//  Warsaw_Tram
//
//  Created by Małgorzata Dziubich on 30/06/16.
//  Copyright © 2016 Małgorzata Dziubich. All rights reserved.
//

import UIKit

class StubNSURLSession: NSURLSession {

    var completionHandler: ((NSData!, NSURLResponse!, NSError!) -> Void)?
    static var stubResponse: (data: NSData?, urlResponse: NSURLResponse?, error: NSError?) = (data: nil, urlResponse: nil, error: nil)

    override class func sharedSession() -> NSURLSession {
        return StubNSURLSession()
    }
    

    override func dataTaskWithRequest(request: NSURLRequest, completionHandler: (NSData?, NSURLResponse?, NSError?) -> Void) -> NSURLSessionDataTask {
        self.completionHandler = completionHandler
        return StubTask(response: StubNSURLSession.stubResponse, completionHandler: completionHandler)
    }
    
    class StubTask: NSURLSessionDataTask {
        typealias Response = (data: NSData?, urlResponse: NSURLResponse?, error: NSError?)
        var stubResponse: Response
        let completionHandler: ((NSData!, NSURLResponse!, NSError!) -> Void)?
        
        init(response: Response, completionHandler: ((NSData!, NSURLResponse!, NSError!) -> Void)?) {
            self.stubResponse = response
            self.completionHandler = completionHandler
        }
        override func resume() {
            completionHandler!(stubResponse.data, stubResponse.urlResponse, stubResponse.error)
        }
    }
}
