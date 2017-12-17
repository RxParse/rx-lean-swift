//
//  AVValidationSMS.swift
//  RxLeanCloudSwift
//
//  Created by WuJun on 14/12/2017.
//  Copyright © 2017 LeanCloud. All rights reserved.
//

import Foundation
import RxSwift

public class AVSMS {
    public var app: AVApp
    public var mobilePhoneNumber: String = ""

    public init(mobilePhoneNumber: String) {
        self.mobilePhoneNumber = mobilePhoneNumber
        self.app = AVClient.sharedInstance.takeApp(app: nil)
    }
}

public class AVUserAuthSMS: AVSMS {
    public func send() -> Observable<Bool> {
        var payload = [String: Any]()
        payload["mobilePhoneNumber"] = self.mobilePhoneNumber
        let cmd = AVCommand(relativeUrl: "/requestLoginSmsCode", method: "POST", data: payload, app: self.app)
        return AVClient.sharedInstance.runCommand(cmd: cmd).map({ (avResponse) -> Bool in
            return avResponse.satusCode == 200
        })
    }
    public var shortCode: String? = nil
    public func setShortCode(receivedShortCode: String) {
        self.shortCode = receivedShortCode
    }
}

public class AVValidationSMS: AVSMS {
    public static func send(mobilePhoneNumber: String, ttl: Int = 10) -> Observable<Bool> {
        return AVValidationSMS.send(mobilePhoneNumber: mobilePhoneNumber, appName: nil, operationName: nil)
    }
    public static func send(mobilePhoneNumber: String, appName: String?, operationName: String?, ttl: Int? = 10) -> Observable<Bool> {
        let sms = AVValidationSMS(mobilePhoneNumber: mobilePhoneNumber, appName: appName, operationName: operationName, ttl: ttl)
        return sms.send()
    }

    public var operationName: String? = nil
    public var ttl: Int = 10
    public var appName: String?

    var shortCode: String? = nil

    public init(mobilePhoneNumber: String, appName: String?, operationName: String?, ttl: Int?) {
        self.operationName = operationName
        self.appName = appName
        if ttl != nil {
            self.ttl = ttl!
        }
        super.init(mobilePhoneNumber: mobilePhoneNumber)
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

    public func setShortCode(receivedShortCode: String) {
        self.shortCode = receivedShortCode
    }

    public func verify() -> Observable<Bool> {
        if self.shortCode != nil {
            let cmd = AVCommand(relativeUrl: "/verifySmsCode/\(String(describing: self.shortCode))?mobilePhoneNumber=\(self.mobilePhoneNumber)", method: "POST", data: nil, app: self.app)
            return AVClient.sharedInstance.runCommand(cmd: cmd).map({ (avResponse) -> Bool in
                return avResponse.satusCode == 200
            })
        }
        return Observable.from([false])
    }
}

public class AVNoticeSMS: AVSMS {

    public init(mobilePhoneNumber: String, templateId: String, signatureId: String?, contentParameters: [String: Any]?) {
        self.templateId = templateId
        self.signatureId = signatureId
        self.contentParameters = contentParameters
        super.init(mobilePhoneNumber: mobilePhoneNumber)
    }
    public var templateId: String = ""
    public var signatureId: String? = nil
    public var contentParameters: [String: Any]? = nil
    public func send() -> Observable<Bool> {
        var payload = [String: Any]()

        payload["mobilePhoneNumber"] = self.mobilePhoneNumber
        payload["template"] = self.templateId

        if self.signatureId != nil {
            payload["sign"] = self.signatureId
        }
        if let env = contentParameters {
            env.forEach({ (key, value) in
                payload[key] = value
            })
        }

        let cmd = AVCommand(relativeUrl: "/requestSmsCode", method: "POST", data: payload, app: self.app)
        return AVClient.sharedInstance.runCommand(cmd: cmd).map({ (avResponse) -> Bool in
            return avResponse.satusCode == 200
        })
    }
}




