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

    public static func initialize(app: RxAVApp) {
        RxAVClient.sharedInstance.add(app: app, replace: true)
    }

    var remoteApps = Array<RxAVApp>()
    public func add(app: RxAVApp, replace: Bool?) {
        self.remoteApps.append(app)
    }

    public func getCurrentApp() -> RxAVApp {
        return self.remoteApps.first!
    }

    public func httpLog() -> Void {
        
    }
}
