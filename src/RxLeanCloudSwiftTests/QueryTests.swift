//
//  QueryTests.swift
//  RxLeanCloudSwiftTests
//
//  Created by WuJun on 16/12/2017.
//  Copyright © 2017 LeanCloud. All rights reserved.
//

import XCTest
import RxLeanCloudSwift
import RxTest
import RxBlocking

class QueryTests: LeanCloudUnitTestBase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testFind() {
        let query = AVQuery<AVObject>(className: "SwiftTodo")
        let result = query.find().toBlocking().materialize()

        switch result {
        case .completed(let elements):
            print(elements[0].count)
            //XCTFail("Expected result to complete with error, but result was successful.")
        case .failed(_, let error):
            print(error.localizedDescription)
        }
    }

    func testCQL() {
        let cql = AVCQL<AVObject>(cql: "select * from SwiftTodo where foo=?")
        cql.placeholders = ["xx"];
        let result = cql.execute().toBlocking().materialize()

        switch result {
        case .completed(let elements):
            print(elements[0].count)
            //XCTFail("Expected result to complete with error, but result was successful.")
        case .failed(_, let error):
            print(error.localizedDescription)
        }
    }


}
