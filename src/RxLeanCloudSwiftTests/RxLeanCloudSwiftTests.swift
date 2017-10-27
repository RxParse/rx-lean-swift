//
//  RxLeanCloudSwiftTests.swift
//  RxLeanCloudSwiftTests
//
//  Created by WuJun on 22/05/2017.
//  Copyright © 2017 LeanCloud. All rights reserved.
//

import XCTest

import RxSwift
import RxTest

class RxLeanCloudSwiftTests: XCTestCase {
    private var observer: TestableObserver<Int>!
    let numbers: Array<Int?> = [1, nil, Int?(3), 4]
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.

        let scheduler = TestScheduler(initialClock: 0)
        observer = scheduler.createObserver(Int.self)
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.

    }
    func testMap_Range() {
        // Initializes test scheduler.
        // Test scheduler implements virtual time that is
        // detached from local machine clock.
        // This enables running the simulation as fast as possible
        // and proving that all events have been handled.
        let scheduler = TestScheduler(initialClock: 0)

        // Creates a mock hot observable sequence.
        // The sequence will emit events at designated
        // times, no matter if there are observers subscribed or not.
        // (that's what hot means).
        // This observable sequence will also record all subscriptions
        // made during its lifetime (`subscriptions` property).
        let xs = scheduler.createHotObservable([
            next(150, 1), // first argument is virtual time, second argument is element value
            next(210, 0),
            next(220, 1),
            next(230, 2),
            next(240, 4),
            completed(300) // virtual time when completed is sent
            ])

        // `start` method will by default:
        // * Run the simulation and record all events
        //   using observer referenced by `res`.
        // * Subscribe at virtual time 200
        // * Dispose subscription at virtual time 1000
        let res = scheduler.start { xs.map { $0 * 2 } }

        let correctMessages = [
            next(210, 0 * 2),
            next(220, 1 * 2),
            next(230, 2 * 2),
            next(240, 4 * 2),
            completed(300)
        ]

        let correctSubscriptions = [
            Subscription(200, 300)
        ]

        XCTAssertEqual(res.events, correctMessages)
        XCTAssertEqual(xs.subscriptions, correctSubscriptions)
    }
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
