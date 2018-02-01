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

//    public var app: AVApp { get set}

    public static func initialize() {

        let app: LeanCloudApp = LeanCloudApp(appId: "uay57kigwe0b6f5n0e1d4z4xhydsml3dor24bzwvzr57wdap", appKey: "kfgz7jjfsk55r5a8a3y4ttd3je1ko11bkibcikonk32oozww")
        app.api = "https://api.aaabbbccc.com"
        app.rtmRouter = "http://rtmrouter.aaabbbccc.com"
        let sdk = RxAVClient.initialize(app: app)

        let qcloudApp = LeanCloudApp(appId: "67L3JTrHzTJy688HoJyYbp0J-9Nh9j0Va", appKey: "8MCnFUHUOJcN6l23T09nHojs", region: .Public_East_CN)
        _ = sdk.add(app: qcloudApp,replace: true)
        _ = sdk.toggleLog(enable: true)
    }
}
