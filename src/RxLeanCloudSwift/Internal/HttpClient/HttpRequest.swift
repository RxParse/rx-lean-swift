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
    var data: Data?

    init(method: String, url: String, headers: Dictionary<String, String>?, data: Data?) {
        self.url = url
        self.headers = headers
        self.data = data
        self.method = method
    }
    convenience init(method: String, url: String, headers: Dictionary<String, String>?, jsonData: Dictionary<String, Any>?) {
        let data = jsonData?.binarization()
        self.init(method: method, url: url, headers: headers, data: data)
    }
}
