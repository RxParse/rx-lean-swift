//
//  AVCommand.swift
//  RxLeanCloudSwift
//
//  Created by WuJun on 22/05/2017.
//  Copyright © 2017 LeanCloud. All rights reserved.
//

import Foundation
import RxSwift

public class AVCommand: HttpRequest {
    var relativeUrl: String = ""
    var app: LeanCloudApp
    public var apiSessionToken: String? {
        get {
            if self.headers != nil {
                return self.headers?["X-LC-Session"];
            }
            return nil
        }
        set {
            if self.headers == nil {
                self.headers = [String: String]()
            }
            if let s = newValue {
                self.headers!["X-LC-Session"] = s
            }
        }
    }

    var dataJsonfy: [String: Any]? {
        get {
            if let data = self.data {
                return data.jsonfy()
            }
            return nil
        }
    }

    func takeUrl(app: LeanCloudApp) -> String {
        self.url = app.getUrl(relativeUrl: self.relativeUrl)
        return self.url
    }

    init(relativeUrl: String, method: String, data: Dictionary<String, Any>?, app: LeanCloudApp?) {
        let _app = RxAVClient.sharedInstance.takeApp(app: app)
        self.app = _app
        let url = self.app.getUrl(relativeUrl: relativeUrl)
        let headers = self.app.getHeaders()
        self.relativeUrl = relativeUrl
        super.init(method: method, url: url, headers: headers, data: data?.binarization())
    }

    public static func create(json: [String: Any], app: LeanCloudApp) -> AVCommand {
        return AVCommand(relativeUrl: "", method: "POST", data: json, app: app)
    }

    public func beforeExecute() -> Observable<AVCommand> {
        return self.app.currentUser().map({ (user) -> AVCommand in
            if let sesstionToken = user?.sessionToken, self.apiSessionToken == nil {
                self.apiSessionToken = sesstionToken
            }
            return self
        })
    }
}
