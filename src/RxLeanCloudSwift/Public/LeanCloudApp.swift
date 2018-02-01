//
//  AVApp.swift
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

public enum AVRegion {
    case Public_North_CN
    case Public_East_CN
    case Public_North_US
    case Private_Custom
}

public class LeanCloudApp {
    var appId: String
    var appKey: String
    var region: AVRegion
    var apiVersion: String = "/1.1"
    var schema: String = "https://"
    public var api: String = GlobalConst.api_public_north_cn
    public var engine: String = GlobalConst.api_public_north_cn
    var stats: String = GlobalConst.api_public_north_cn
    var push: String = GlobalConst.api_public_north_cn
    public var rtmRouter: String = GlobalConst.push_router_public_north_cn
    var wss: String?
    var shortName: String = "default"
    var userCacheKey: String = "currentUser";
    var installationCacheKey: String = "currentInstallation"

    public init(appId: String, appKey: String, region: AVRegion = AVRegion.Public_North_CN, shortName: String? = "default", secure: Bool? = true) {
        self.appId = appId
        self.appKey = appKey
        self.region = region

        switch region {
        case .Public_East_CN: do {
                self.api = "\(schema)\(GlobalConst.api_public_east_cn)"
                self.engine = "\(schema)\(GlobalConst.api_public_east_cn)"
                self.stats = "\(schema)\(GlobalConst.api_public_east_cn)"
                self.push = "\(schema)\(GlobalConst.api_public_east_cn)"
                self.rtmRouter = "\(schema)\(GlobalConst.push_router_public_east_cn)"
            }
        case .Public_North_US: do {
                self.api = "\(schema)\(GlobalConst.api_public_north_us)"
                self.engine = "\(schema)\(GlobalConst.api_public_north_us)"
                self.stats = "\(schema)\(GlobalConst.api_public_north_us)"
                self.push =  "\(schema)\(GlobalConst.api_public_north_us)"
            self.rtmRouter = "\(schema)\(GlobalConst.push_router_public_north_us)"
            }
        default:
            let index = self.appId.index(self.appId.startIndex, offsetBy: 8)
            let appSubDomain = self.appId[...index]
            self.api = "\(schema)\(appSubDomain).api.lncld.net"
            self.engine = "\(schema)\(appSubDomain).engine.lncld.net"
            self.stats = "\(schema)\(appSubDomain).stats.lncld.net"
            self.push = "\(schema)\(appSubDomain).push.lncld.net"
            self.rtmRouter = "\(schema)\(appSubDomain).rtm.lncld.net"
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
            return "\(push)\(apiVersion)\(relativeUrl)"
        }
        return "\(api)\(apiVersion)\(relativeUrl)"
    }

    public func getRTMRouterUrl() -> String {
        return "\(self.rtmRouter)/v1/route?appId=\(self.appId)&secure=1"
    }

    public func getUserStorageKey() -> String {
        return "\(self.appId)_\(self.userCacheKey)";
    }

    public func getFileUploader() -> IFileUploader {
        switch self.region {
        default:
            return QiniuFileUploader(httpClient: AVCorePlugins.sharedInstance.httpClient)
        }
    }

    public func currentUser() -> Observable<RxAVUser?> {
        let key = self.getUserStorageKey()
        return AVCorePlugins.sharedInstance.kvStorageController.get(key: key).map({ (userDataString) -> RxAVUser? in
            if userDataString != nil {
                let userData = userDataString?.toDictionary()
                let serverState = AVCorePlugins.sharedInstance.objectDecoder.decode(serverResult: userData as [String: Any]!, decoder: AVCorePlugins.sharedInstance.avDecoder)
                let user = RxAVUser()
                user.handleLogInResult(serverState: serverState, app: self)
                return user
            } else {
                return nil
            }
        })
    }
}

