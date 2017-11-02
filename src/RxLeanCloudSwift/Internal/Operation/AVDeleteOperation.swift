//
//  AVDeleteOperation.swift
//  RxLeanCloudSwift
//
//  Created by WuJun on 02/11/2017.
//  Copyright © 2017 LeanCloud. All rights reserved.
//

import Foundation

public class AVDeleteToken {
    public static let sharedInstance = AVDeleteToken()
}

public class AVDeleteOperation: IAVFieldOperation {
    var deleteToken: AVDeleteToken
    public static let sharedInstance = AVDeleteOperation()
    init() {
        self.deleteToken = AVDeleteToken.sharedInstance
    }
    public func encode() -> Any {
        //return RxAVCorePlugins.sharedInstance.avEncoder.encode(value: self.value)
        return ["__op": "Delete"];
    }

    public func mergeWithPrevious(previous: IAVFieldOperation?) -> IAVFieldOperation {
        return self
    }

    public func apply(oldValue: Any?, key: String) -> Any {
        return self.deleteToken
    }
}
