//
//  init.swift
//  RxLeanCloudSwiftTests
//
//  Created by WuJun on 27/10/2017.
//  Copyright © 2017 LeanCloud. All rights reserved.
//

import Foundation
import RxLeanCloudSwift

class RxLeanCloudSwiftUtils {

    static let sharedInstance = RxLeanCloudSwiftUtils()

//    public var app: RxAVApp { get set}
    
    public static func initialize() {
        let app: RxAVApp = RxAVApp(appId: "uay57kigwe0b6f5n0e1d4z4xhydsml3dor24bzwvzr57wdap", appKey: "kfgz7jjfsk55r5a8a3y4ttd3je1ko11bkibcikonk32oozww")
        let sdk = RxAVClient.initialize(app: app)
        sdk.toggleLog(enable: true)
    }
}
