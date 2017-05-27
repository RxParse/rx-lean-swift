//
//  HttpRequest.swift
//  RxLeanCloudSwift
//
//  Created by WuJun on 22/05/2017.
//  Copyright © 2017 LeanCloud. All rights reserved.
//

import Foundation

public class HttpRequest {
    var method: String
    var url: String
    var headers: Dictionary<String, String>?
    var data: Dictionary<String, Any>?

    init(method: String, url: String, headers: Dictionary<String, String>?, data: Dictionary<String, Any>?) {
        self.url = url
        self.headers = headers
        self.data = data
        self.method = method
    }
}
