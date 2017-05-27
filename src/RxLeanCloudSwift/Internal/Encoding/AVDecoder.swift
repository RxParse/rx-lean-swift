//
//  AVDecoder.swift
//  RxLeanCloudSwift
//
//  Created by WuJun on 24/05/2017.
//  Copyright © 2017 LeanCloud. All rights reserved.
//

import Foundation

public class AVDecoder: IAVDecoder {

    public func decode(value: Any) -> Any {

        if value is [String: Any] {
            var dataMap = value as! [String: Any]
            if dataMap["__type"] == nil {
                var newMap = [String: Any]()
                for (key, value) in dataMap {
                    newMap[key] = decode(value: value)
                }
                return newMap;
            } else {
                let typeString = dataMap["__type"] as! String
                if typeString == "Date" {
                    let formatter = RxAVCorePlugins.dateFormatter
                    let dateString = dataMap["iso"] as! String
                    return formatter.date(from: dateString) as Any
                } else if typeString == "Pointer" {
                    let className = dataMap["className"] as! String
                    let objectId = dataMap["objectId"] as! String
                    return self.decodePotinter(className: className, objectId: objectId)
                }
            }
        }

        return value
    }

    public func decodePotinter(className: String, objectId: String) -> RxAVObject {
        return RxAVObject.createWithoutData(classnName: className, objectId: objectId);
    }

    public func clone(dictionary: [String: Any]) -> [String: Any] {
        var cloned = [String: Any]()
        for (key, value) in dictionary {
            cloned[key] = value
        }
        return cloned
    }
}
