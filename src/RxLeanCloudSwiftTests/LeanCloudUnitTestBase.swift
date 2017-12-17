//
//  LeanCloudUnitTestBase.swift
//  RxLeanCloudSwiftTests
//
//  Created by WuJun on 16/12/2017.
//  Copyright © 2017 LeanCloud. All rights reserved.
//

import XCTest

class LeanCloudUnitTestBase: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        RxLeanCloudSwiftUtils.initialize()
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
}
