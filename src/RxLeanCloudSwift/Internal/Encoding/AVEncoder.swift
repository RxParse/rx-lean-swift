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
        } else if self.isAVObject(value: value) {
            return encodeAVObject(avObject: value as! RxAVObject)
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
        } else if value is Array<Any> {
            let encodedArray = self.encodeArray(list: value as! Array<Any>)
            return encodedArray
        }
        return value
    }

    public func encodeDate(date: Date) -> [String: Any] {
        let formatter = AVCorePlugins.dateFormatter
        var encoded = [String: Any]()
        encoded["__type"] = "Date"
        encoded["iso"] = formatter.string(from: date)
        return encoded
    }

    public func encodeAVObject(avObject: RxAVObject) -> [String: Any] {
        var encoded = [String: Any]()
        encoded["__type"] = "Pointer"
        encoded["className"] = avObject.className
        encoded["objectId"] = avObject.objectId
        return encoded
    }

    public func encodeArray(list: Array<Any>) -> Array<Any> {
        var resultArray = Array<Any>()
        for item in list {
            if self.isValidType(value: item) {
                let encoedItem = self.encode(value: item)
                resultArray.append(encoedItem)
            }
        }
        return resultArray
    }

    public func isValidType(value: Any) -> Bool {
        return value is String
            || value is Int
            || value is Int8
            || value is Int16
            || value is Int32
            || value is Int64
            || value is RxAVObject
            || value is Date
            || value is Data
            || value is Dictionary<String, Any>
            || value is Array<Any>
    }

    public func isAVObject(value: Any) -> Bool {
        return value is RxAVObject
    }
}
