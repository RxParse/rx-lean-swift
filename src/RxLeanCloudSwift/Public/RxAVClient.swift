//
//  RxAVClient.swift
//  RxLeanCloudSwift
//
//  Created by WuJun on 22/05/2017.
//  Copyright © 2017 LeanCloud. All rights reserved.
//

import Foundation

public class RxAVClient {

    static let sharedInstance = RxAVClient()

    public static func initialize(app: RxAVApp) -> RxAVClient {
        return RxAVClient.sharedInstance.add(app: app, replace: true)
    }

    var remoteApps = Array<RxAVApp>()
    public func add(app: RxAVApp, replace: Bool?) -> RxAVClient {
        self.remoteApps.append(app)
        return self
    }

    public func getCurrentApp() -> RxAVApp {
        return self.remoteApps.first!
    }

    var _enableLog: Bool = false
    public func toggleLog(enable: Bool = true) {
        _enableLog = enable
    }

    public func httpLog(request: HttpRequest, response: HttpResponse) -> Void {
        if _enableLog {
            print("===HTTP-START===")
            print("===Request-START===")
            print("Url: ", request.url)
            print("Method: ", request.method)
            print("Headers: ", request.headers)
            print("RequestBody: ", request.data ?? ["no":"result"])
            print("===Request-END===")
            print("===Response-START===")
            print("StatusCode: ", response.satusCode)
            print("RepsonseBody: ", response.body ?? "")
            print("===Response-END===")
            print("===HTTP-END===")
        }
    }
}
