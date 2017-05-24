//
//  IAVDecoder.swift
//  RxLeanCloudSwift
//
//  Created by WuJun on 24/05/2017.
//  Copyright © 2017 LeanCloud. All rights reserved.
//

import Foundation

public protocol IAVDecoder {
    func decode(value: Any) -> Any
    func clone(dictionary: [String: Any]) -> [String: Any]
}

