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
        } else if self.isRxAVObject(value: value) {
            return encodeRxAVObject(avObject: value as! RxAVObject)
        } else if value is [String: Any] {
            let dic = value as! [String: Any]
            var json = [String: Any]()
            for pair in dic {
                json[pair.key] = self.encode(value: pair.value)
            }
            return json
        } else if value is IAVFieldOperation {
            let operation = value as! IAVFieldOperation
            return operation.encode()
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

    public func encodeRxAVObject(avObject: RxAVObject) -> [String: Any] {
        var encoded = [String: Any]()
        encoded["__type"] = "Pointer"
        encoded["className"] = avObject.className
        encoded["objectId"] = avObject.objectId
        return encoded
    }

    public func isValidType(value: Any) -> Bool {
        return value is String
            || value is RxAVObject
            || value is Date
            || value is Data
            || value is Dictionary<String, Any>
            || value is Array<Any>
    }

    public func isRxAVObject(value: Any) -> Bool {
        return value is RxAVObject
    }
}
