//
//  LeanCloud.swift
//  RxLeanCloudSwift
//
//  Created by WuJun on 15/12/2017.
//  Copyright © 2017 LeanCloud. All rights reserved.
//

import Foundation

public class LeanCloud {
    public static func initialize(applicationID: String, applicationKey: String) -> RxAVClient {
        let app: LeanCloudApp = LeanCloudApp(appId: applicationID, appKey: applicationKey)
        let sdk = RxAVClient.initialize(app: app)
        return sdk
    }
}



