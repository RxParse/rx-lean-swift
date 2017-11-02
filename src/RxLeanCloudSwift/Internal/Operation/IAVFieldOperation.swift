//
//  IAVFieldOperation.swift
//  RxLeanCloudSwift
//
//  Created by WuJun on 02/11/2017.
//  Copyright © 2017 LeanCloud. All rights reserved.
//

import Foundation

public protocol IAVFieldOperation {
    func encode() -> Any
    func mergeWithPrevious(previous: IAVFieldOperation?) -> IAVFieldOperation
    func apply(oldValue: Any?, key: String) -> Any
}
