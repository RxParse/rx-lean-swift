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
    var realtiveUrl: String = ""
    var app: AVApp
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
    func takeUrl(app: AVApp) -> String {
        self.url = app.getUrl(relativeUrl: self.realtiveUrl)
        return self.url
    }

    init(relativeUrl: String, method: String, data: Dictionary<String, Any>?, app: AVApp?) {
        let _app = AVClient.sharedInstance.takeApp(app: app)
        self.app = _app
        let url = self.app.getUrl(relativeUrl: relativeUrl)
        let headers = self.app.getHeaders()
        self.realtiveUrl = relativeUrl
        super.init(method: method, url: url, headers: headers, data: data)
    }

    public static func create(json: [String: Any], app: AVApp) -> AVCommand {
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
