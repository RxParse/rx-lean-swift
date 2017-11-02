//
//  RxAVApp.swift
//  RxLeanCloudSwift
//
//  Created by WuJun on 22/05/2017.
//  Copyright © 2017 LeanCloud. All rights reserved.
//

import Foundation
import RxSwift

struct GlobalConst {
    static let api_public_north_cn = "api.leancloud.cn"
    static let push_router_public_north_cn = "router.g0.push.leancloud.cn"
    static let api_public_east_cn = "e1-api.leancloud.cn"
    static let push_router_public_east_cn = "router-q0-push.leancloud.cn"
    static let api_public_north_us = "us-api.leancloud.cn";
    static let push_router_public_north_us = "router-a0-push.leancloud.cn";
}

public enum RxAVRegion {
    case Public_North_CN
    case Public_East_CN
    case Public_North_US
    case Private_Custom
}

public class RxAVApp {
    var appId: String
    var appKey: String
    var apiVersion: String = "/1.1"
    var schema: String = "https://"
    var api: String = GlobalConst.api_public_north_cn
    var engine: String = GlobalConst.api_public_north_cn
    var stats: String = GlobalConst.api_public_north_cn
    var push: String = GlobalConst.api_public_north_cn
    var pushRouter: String = GlobalConst.push_router_public_north_cn
    var wss: String?
    var shortName: String = "default"
    var userCacheKey: String = "currentUser";
    var installationCacheKey: String = "currentInstallation"

    public init(appId: String, appKey: String, region: RxAVRegion = RxAVRegion.Public_North_CN, shortName: String? = "default", secure: Bool? = true) {
        self.appId = appId
        self.appKey = appKey

        switch region {
        case .Public_East_CN: do {
                self.api = GlobalConst.api_public_east_cn
                self.engine = GlobalConst.api_public_east_cn
                self.stats = GlobalConst.api_public_east_cn
                self.push = GlobalConst.api_public_east_cn
                self.pushRouter = GlobalConst.push_router_public_east_cn
            }
        case .Public_North_US: do {
                self.api = GlobalConst.api_public_north_us
                self.engine = GlobalConst.api_public_north_us
                self.stats = GlobalConst.api_public_north_us
                self.push = GlobalConst.api_public_north_us
                self.pushRouter = GlobalConst.push_router_public_north_us
            }
        default:
            let index = self.appId.index(self.appId.startIndex, offsetBy: 8)
            let appSubDomain = self.appId[...index]
            self.api = "\(appSubDomain).api.lncld.net"
            self.engine = "\(appSubDomain).engine.lncld.net"
            self.stats = "\(appSubDomain).stats.lncld.net"
            self.push = "\(appSubDomain).push.lncld.net"
            self.pushRouter = "\(appSubDomain).rtm.lncld.net"
        }
    }

    public func getHeaders() -> Dictionary<String, String> {
        var headers: Dictionary<String, String> = [:]
        headers["X-LC-Id"] = self.appId
        headers["X-LC-Key"] = self.appKey
        headers["Content-Type"] = "application/json"
        return headers
    }

    public func getUrl(relativeUrl: String) -> String {
        if relativeUrl.hasPrefix("/push") {
            return "\(schema)\(push)\(apiVersion)\(relativeUrl)"
        }
        return "\(schema)\(api)\(apiVersion)\(relativeUrl)"
    }

    public func getPushRouterUrl() -> String {
        return "https://\(self.pushRouter)/v1/route?appId=\(self.appId)&secure=1"
    }

    public func getUserStorageKey() -> String {
        return "\(self.appId)_\(self.userCacheKey)";
    }

    public func currentUser() -> Observable<RxAVUser?> {
        let key = self.getUserStorageKey()
        return RxAVCorePlugins.sharedInstance.kvStorageController.get(key: key).map({ (userDataString) -> RxAVUser? in
            if userDataString != nil {
                let userData = userDataString?.toDictionary()
                let serverState = RxAVCorePlugins.sharedInstance.objectDecoder.decode(serverResult: userData as [String: Any]!, decoder: RxAVCorePlugins.sharedInstance.avDecoder)
                let user = RxAVUser()
                user.handleLogInResult(serverState: serverState, app: self)
                return user
            } else {
                return nil
            }
        })
    }
}

