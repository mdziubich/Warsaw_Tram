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
    let data = ["result": [["Brigade": "6", "FirstLine": "1", "Lat": 52.2164497, "Lines": "1", "Lon": 21.005352, "LowFloor": 0, "Status": "RUNNING", "Time": "2016-07-01T21:27:43"], ["Brigade": "5", "FirstLine": "35 ", "Lat": 52.1678963, "Lines": "35             ", "Lon": 21.0159893, "LowFloor": 1, "Status": "RUNNING", "Time": "2016-07-01T21:27:43"], ["Brigade": "2   ", "FirstLine": "2  ", "Lat": 52.3192101, "Lines": "2              ", "Lon": 20.9513645, "LowFloor": 1, "Status": "FINISHED", "Time": "2016-07-01T21:27:43"]]]
    
    override func setUp() {
        tramViewModel = TramViewModel()
        super.setUp()
    }
    
    func testFetchTramsNumbers() {
        do {
            let jsonData = try NSJSONSerialization.dataWithJSONObject(data, options: [])
            let urlResponse = NSHTTPURLResponse(URL: NSURL(string: "https://api.um.warszawa.pl/api/action/wsstore_get")!, statusCode: 200, HTTPVersion: nil, headerFields: nil)
            StubNSURLSession.stubResponse = (jsonData, urlResponse: urlResponse, error: nil)
            tramViewModel.session = StubNSURLSession.self
            
            let expectation = self.expectationWithDescription("testFetchTramsNumbers")
            
            tramViewModel.fetchTramsNumbers({ (trams, lowFloorTrams) in
                XCTAssertEqual(String(trams[0]), "1", "Incorrect tram number.")
                XCTAssertEqual(String(trams[1]), "35", "Incorrect tram number.")
                XCTAssertEqual(String(lowFloorTrams[0]), "35", "Incorrect low floor tram number.")

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
    
    // Test should return selected tram nuber without low floor filter
    func testFetchTramsForMap() {

        let expectation = self.expectationWithDescription("testFetchTramsForMap")

        do {
            let jsonData = try NSJSONSerialization.dataWithJSONObject(data, options: [])
            let urlResponse = NSHTTPURLResponse(URL: NSURL(string: "https://api.um.warszawa.pl/api/action/wsstore_get")!, statusCode: 200, HTTPVersion: nil, headerFields: nil)
            StubNSURLSession.stubResponse = (jsonData, urlResponse: urlResponse, error: nil)
            tramViewModel.session = StubNSURLSession.self
            
            let tramsParameters = DisplayedTramsData(tramNumber: "1", showAllTrams: false, lowFloorFilter: false)
            tramViewModel.fetchTramsForMap(tramsParameters, success: { (trams) in
                
                XCTAssertEqual(trams[0].number, "1", "Wrong tram number.")
                XCTAssertFalse(trams[0].lowFloor, "The tram lowFloor status should be false")
                
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
    
    // Test should return all trams without low floor filter
    func testFetchTramsForMap2() {
        
        let expectation = self.expectationWithDescription("testFetchTramsForMap2")
        
        do {
            let jsonData = try NSJSONSerialization.dataWithJSONObject(data, options: [])
            let urlResponse = NSHTTPURLResponse(URL: NSURL(string: "https://api.um.warszawa.pl/api/action/wsstore_get")!, statusCode: 200, HTTPVersion: nil, headerFields: nil)
            StubNSURLSession.stubResponse = (jsonData, urlResponse: urlResponse, error: nil)
            tramViewModel.session = StubNSURLSession.self
            
            let tramsParameters = DisplayedTramsData(tramNumber: "1", showAllTrams: true, lowFloorFilter: false)
            tramViewModel.fetchTramsForMap(tramsParameters, success: { (trams) in
                
                XCTAssertEqual(trams[0].number, "1", "Wrong tram number.")
                XCTAssertEqual(trams[1].number, "35", "Wrong tram number.")
                XCTAssertFalse(trams[0].lowFloor, "The tram lowFloor status should be false")
                XCTAssertTrue(trams[1].lowFloor, "The tram lowFloor status should be true")
                
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
    
    // Test should return selected tram nuber with low floor filter
    func testFetchTramsForMap3() {
        
        let expectation = self.expectationWithDescription("testFetchTramsForMap3")
        
        do {
            let jsonData = try NSJSONSerialization.dataWithJSONObject(data, options: [])
            let urlResponse = NSHTTPURLResponse(URL: NSURL(string: "https://api.um.warszawa.pl/api/action/wsstore_get")!, statusCode: 200, HTTPVersion: nil, headerFields: nil)
            StubNSURLSession.stubResponse = (jsonData, urlResponse: urlResponse, error: nil)
            tramViewModel.session = StubNSURLSession.self
            
            let tramsParameters = DisplayedTramsData(tramNumber: "35", showAllTrams: false, lowFloorFilter: true)
            tramViewModel.fetchTramsForMap(tramsParameters, success: { (trams) in
                
                XCTAssertEqual(trams[0].number, "35", "Wrong tram number.")
                XCTAssertTrue(trams[0].lowFloor, "The tram lowFloor status should be true")
                
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
