//
//  AVCommandResponse.swift
//  RxLeanCloudSwift
//
//  Created by WuJun on 23/05/2017.
//  Copyright © 2017 LeanCloud. All rights reserved.
//

import Foundation

public class AVCommandResponse: HttpResponse {

    private var _jsonBody: [String: Any]? = nil
    public override var jsonBody: [String: Any]? {
        get {
            if self._jsonBody != nil {
                return self._jsonBody
            }
            return super.jsonBody
        }
    }

    init(statusCode: Int, jsonBody: [String: Any]?) {
        super.init(statusCode: statusCode, data: nil)
        self._jsonBody = jsonBody
    }

    override init(statusCode: Int, data: Data?) {
        super.init(statusCode: statusCode, data: data)
    }
}
