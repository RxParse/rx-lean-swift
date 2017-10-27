//
//  HttpResponse.swift
//  RxLeanCloudSwift
//
//  Created by WuJun on 23/05/2017.
//  Copyright © 2017 LeanCloud. All rights reserved.
//

import Foundation

public class HttpResponse {
    var satusCode: Int = -1
    var data: Data?

    var bodyString: String {
        get {
            if self.data != nil {
                return String(data: self.data!, encoding: .utf8)!
            }
            return "";
        }
    }

    var jsonBody: [String: Any]? {
        get {
            if self.data != nil {
                let utf8DecodedString = String(data: self.data!, encoding: .utf8)
                let json = utf8DecodedString?.toDictionary()
                if json != nil {
                    return json
                }
            }
            return nil
        }
    }

    init(statusCode: Int, data: Data?) {
        self.satusCode = statusCode
        self.data = data
    }
}
