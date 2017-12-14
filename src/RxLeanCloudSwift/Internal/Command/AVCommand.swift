//
//  AVCommand.swift
//  RxLeanCloudSwift
//
//  Created by WuJun on 22/05/2017.
//  Copyright © 2017 LeanCloud. All rights reserved.
//

import Foundation

public class AVCommand: HttpRequest {
    var realtiveUrl: String = ""

    func takeUrl(app: AVApp) -> String {
        self.url = app.getUrl(relativeUrl: self.realtiveUrl)
        return self.url
    }

    init(relativeUrl: String, method: String, data: Dictionary<String, Any>?, app: AVApp?) {
        let _app = AVClient.sharedInstance.takeApp(app: app)
        let url = _app.getUrl(relativeUrl: relativeUrl)
        let headers = _app.getHeaders()
        self.realtiveUrl = relativeUrl
        super.init(method: method, url: url, headers: headers, data: data)
    }

    public static func create(json: [String: Any], app: AVApp) -> AVCommand {
        return AVCommand(relativeUrl: "", method: "POST", data: json, app: app)
    }
}
