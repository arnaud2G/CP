//
//  SearchTest.swift
//  CP
//
//  Created by 2Gather Arnaud Verrier on 12/12/2016.
//  Copyright © 2016 Arnaud Verrier. All rights reserved.
//

import XCTest

class SearchTest: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        let search = SearchViewController()
        let expe = expectation(description: "asynchronous request")
        search.search(location: "43 Quai du Président Roosevelt, 92130 Issy-les-Moulineaux, France", completion: {
            (locations:[Location]) -> Void in
            if locations.count != 1 {
                return
            }
            let location = locations.first!
            if location.title! != "43 Quai du Président Roosevelt" || location.adress! != "43 Quai du Président Roosevelt, 92130 Issy-les-Moulineaux, France" || location.latitude != 48.8340459 || location.longitude != 2.2648742 {
                return
            }
            expe.fulfill()
        })
        waitForExpectations(timeout: 2, handler: nil)
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
}
