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
    var body : Any?
    
    init(statusCode:Int, body: [String:Any]?) {
        self.satusCode = statusCode
        self.body = body
    }
}
