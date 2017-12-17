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

class UserTest: LeanCloudUnitTestBase {

    override func setUp() {
        super.setUp()
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testLogIn() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.

        let result = AVUser.logIn(username: "junwu", password: "leancloud")
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
        let result = AVUser.logIn(username: "junwu", password: "leancloud").flatMap { (user) -> Observable<Bool> in
            return user.saveToStorage()
        }.flatMap({ (success) -> Observable<AVUser?> in
            if success {
                return AVUser.current()
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
    func testSignUp() {
        var user = AVUser()
        user.username = self.randomString(8)
        user.password = "leancloud"
//        user.mobilePhoneNumber = "18612345678"

        let result = user.signUp().toBlocking().materialize()

        switch result {
        case .completed(let elements):
            print(elements[0])
            //XCTFail("Expected result to complete with error, but result was successful.")
        case .failed(let _, let error):
            print(error.localizedDescription)
        }
    }
    func testSaveObjectAfterSignUp() {
        var user = AVUser()
        user.username = self.randomString(8)
        user.password = "leancloud"
        //        user.mobilePhoneNumber = "18612345678"

        let result = user.signUp().flatMap({ (signedUp) -> Observable<AVObject> in
            var todo = AVObject(className: "SwiftTodo")
            todo["tag"] = "monkey"
            return todo.save()
        }).toBlocking().materialize()

        switch result {
        case .completed(let elements):
            print(elements[0])
            //XCTFail("Expected result to complete with error, but result was successful.")
        case .failed(_, let error):
            print(error.localizedDescription)
        }
    }

    func testBecome() {
        let result = AVUser.become(sessionToken: "f14435aglcl8iogb3rbpebsg3").toBlocking().materialize()
        switch result {
        case .completed(let elements):
            print(elements[0])
        case .failed(_, let error):
            print(error.localizedDescription)
        }
    }


    func randomString(_ length: Int) -> String {

        let master = Array("abcdefghijklmnopqrstuvwxyz-ABCDEFGHIJKLMNOPQRSTUVWXYZ_123456789".utf8CString) //0...62 = 63
        var randomString = ""

        for _ in 1...length {
            let random = arc4random_uniform(UInt32(master.count))
            randomString.append(String(master[Int(random)]))
        }
        return randomString
    }

}

