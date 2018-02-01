//
//  SMSTests.swift
//  RxLeanCloudSwiftTests
//
//  Created by WuJun on 19/12/2017.
//  Copyright © 2017 LeanCloud. All rights reserved.
//

import XCTest
import RxLeanCloudSwift
import RxSwift

class SMSTests: LeanCloudUnitTestBase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testAVUserSMSSignUpSend() {

        var user = RxAVUser()
        user.mobilePhoneNumber = "18612438929"
        user.email = "jun.wu@leancloud.rocks"
        user.password = "iwannabeaengineer"
        user.set(key: "nickName", value: "hahaha")

        user.sendSignUpSMS().flatMap { (sms) -> Observable<Bool> in
            sms.setShortCode(receivedShortCode: "064241")
            return user.signUpWithSms(sms: sms)
        }.subscribe(onNext: { (success) in
            if success {
                print("sign up successful")
            }
        })

        let result = user.sendSignUpSMS().flatMap { (sms) -> Observable<Bool> in
            sms.setShortCode(receivedShortCode: "064241")
            return user.signUpWithSms(sms: sms)
            }.toBlocking().materialize()

        switch result {
        case .completed(let elements):
            print(elements[0])
        case .failed(let elements, let error):
            print(error.localizedDescription)
        }
    }
    func testAVUserSMSSignUp() {
        var signUpSMS = AVUserSignUpSMS(mobilePhoneNumber: "18612438929")
        signUpSMS.setShortCode(receivedShortCode: "064241")
        let result = RxAVUser.signUpOrLogIn(sms: signUpSMS).toBlocking().materialize()
        switch result {
        case .completed(let elements):
            print(elements[0].objectId)
        case .failed(let elements, let error):
            print(error.localizedDescription)
        }
    }

}

