//
//  TramViewModelTest.swift
//  Warsaw_Tram
//
//  Created by Małgorzata Dziubich on 30/06/16.
//  Copyright © 2016 Małgorzata Dziubich. All rights reserved.
//

@testable import Warsaw_Tram
import XCTest
import CoreLocation


class TramViewModelTest: XCTestCase {

    var tramViewModel: TramViewModel!
    
    override func setUp() {
        tramViewModel = TramViewModel()
        super.setUp()
    }
    
    func testGetTramsData() {
        
        let data = ["result": [["Brigade": "6", "FirstLine": "1", "Lat": 52.2164497, "Lines": "1", "Lon": 21.005352, "LowFloor": 0, "Status": "RUNNING", "Time": "2016-07-01T21:27:43"]]]
        do {
            let jsonData = try NSJSONSerialization.dataWithJSONObject(data, options: [])
            let urlResponse = NSHTTPURLResponse(URL: NSURL(string: "https://api.um.warszawa.pl/api/action/wsstore_get")!, statusCode: 200, HTTPVersion: nil, headerFields: nil)
            StubNSURLSession.stubResponse = (jsonData, urlResponse: urlResponse, error: nil)
            tramViewModel.session = StubNSURLSession.self
            
            let expectation = self.expectationWithDescription("testGetTramsData")

            tramViewModel.getTramsData({ (trams) in
                XCTAssertEqual(trams[0].number, "1", "Wrong tram number.")
                XCTAssertFalse(trams[0].lowFloor, "The tram lowFloor status should be false")
                XCTAssertEqual(trams[0].status, "RUNNING", "Incorrect tram status.")
                XCTAssertEqual(String(trams[0].latitude), "52.2164497", "Incorrect tram lattitude.")
                XCTAssertEqual(String(trams[0].longitude), "21.005352", "Incorrect tram longitude.")
                
                expectation.fulfill()

                }, failure: { (error) in
                    XCTFail("unexpected error")
                    expectation.fulfill()
            })
            waitForExpectationsWithTimeout(0.5, handler: nil)
        } catch {
            print("tests error: \(error)")
        }
    }
}
