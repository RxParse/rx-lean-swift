//
//  AVEncoder.swift
//  RxLeanCloudSwift
//
//  Created by WuJun on 24/05/2017.
//  Copyright © 2017 LeanCloud. All rights reserved.
//

import Foundation

public class AVEncoder: IAVEncoder {

    public func encode(value: Any) -> Any {
        if value is Date {
            return encodeDate(date: value as! Date)
        } else if value is [UInt8] {
            let string = String(data: value as! Data, encoding: .utf8)
            let bytesMap: [String: String] = ["__type": "Bytes", "base64": string!]
            return bytesMap
        }
        return value
    }

    public func encodeDate(date: Date) -> [String: Any] {
        let formatter = RxAVCorePlugins.dateFormatter

        var encoded = [String: Any]()
        encoded["__type"] = "Date"
        encoded["iso"] = formatter.string(from: date)
        return encoded
    }

    public func isValidType(value: Any) -> Bool {
        return value is String || value is RxAVObject || value is Date
    }
}
