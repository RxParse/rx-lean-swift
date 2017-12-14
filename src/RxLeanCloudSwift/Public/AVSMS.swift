//
//  AVSMS.swift
//  RxLeanCloudSwift
//
//  Created by WuJun on 14/12/2017.
//  Copyright © 2017 LeanCloud. All rights reserved.
//

import Foundation
import RxSwift

public class AVSMS {
    public static func send(mobilePhoneNumber: String, ttl: Int = 10) -> Observable<Bool> {
        return AVSMS.send(mobilePhoneNumber: mobilePhoneNumber, appName: nil, operationName: nil)
    }
    public static func send(mobilePhoneNumber: String, appName: String?, operationName: String?, ttl: Int? = 10) -> Observable<Bool> {
        let sms = AVSMS(mobilePhoneNumber: mobilePhoneNumber, appName: appName, operationName: operationName, ttl: ttl)
        return sms.send()
    }

    public var mobilePhoneNumber: String = ""
    public var operationName: String? = nil
    public var ttl: Int = 10
    public var appName: String?
    public var app: AVApp

    public init(mobilePhoneNumber: String, appName: String?, operationName: String?, ttl: Int?) {
        self.mobilePhoneNumber = mobilePhoneNumber
        self.operationName = operationName
        self.appName = appName
        if ttl != nil {
            self.ttl = ttl!
        }
        self.app = AVClient.sharedInstance.takeApp(app: nil)
    }

    public func send() -> Observable<Bool> {
        var payload = [String: Any]()
        payload["mobilePhoneNumber"] = self.mobilePhoneNumber
        if self.operationName != nil {
            payload["op"] = self.operationName
        }
        if self.appName != nil {
            payload["name"] = self.appName
        }
        if self.ttl != 10 {
            payload["ttl"] = self.ttl
        }
        let cmd = AVCommand(relativeUrl: "/requestSmsCode", method: "POST", data: payload, app: self.app)
        return AVClient.sharedInstance.runCommand(cmd: cmd).map({ (avResponse) -> Bool in
            return avResponse.satusCode == 200
        })
    }
}




