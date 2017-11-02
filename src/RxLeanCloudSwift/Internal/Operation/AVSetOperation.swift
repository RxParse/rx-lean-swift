//
//  AVSetOperation.swift
//  RxLeanCloudSwift
//
//  Created by WuJun on 02/11/2017.
//  Copyright © 2017 LeanCloud. All rights reserved.
//

import Foundation

public class AVSetOperation: IAVFieldOperation {
    var value: Any
    init(value: Any) {
        self.value = value
    }
    public func encode() -> Any {
        return RxAVCorePlugins.sharedInstance.avEncoder.encode(value: self.value)
    }

    public func mergeWithPrevious(previous: IAVFieldOperation?) -> IAVFieldOperation {
        return self
    }

    public func apply(oldValue: Any?, key: String) -> Any {
        return self.value
    }
}
