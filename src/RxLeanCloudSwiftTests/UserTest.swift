//
//  UserTest.swift
//  RxLeanCloudSwiftTests
//
//  Created by WuJun on 27/10/2017.
//  Copyright © 2017 LeanCloud. All rights reserved.
//

import XCTest
import RxLeanCloudSwift
import RxSwift

class UserTest: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        RxLeanCloudSwiftUtils.initialize()
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testLogIn() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.

        let result = RxAVUser.logIn(username: "junwu", password: "leancloud")
            .toBlocking()
            .materialize()

        switch result {
        case .completed(let elements):
            print(elements[0].mobilePhoneVerified)
            //XCTFail("Expected result to complete with error, but result was successful.")
        case .failed(let elements, let error):
            print(error.localizedDescription)
        }
    }

    func testLogInGetCurrentUser() {
        let result = RxAVUser.logIn(username: "junwu", password: "leancloud").flatMap { (user) -> Observable<Bool> in
            return user.saveToStorage()
        }.flatMap({ (success) -> Observable<RxAVUser?> in
            if success {
                return RxAVUser.current()
            }
            return Observable.from(nil)

        }).toBlocking().materialize()

        switch result {
        case .completed(let elements):
            let user = elements[0]
            print(["sessionToken", user!.sessionToken, "username", user!.username])
            //XCTFail("Expected result to complete with error, but result was successful.")
        case .failed(let elements, let error):
            print(error.localizedDescription)
        }
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}

