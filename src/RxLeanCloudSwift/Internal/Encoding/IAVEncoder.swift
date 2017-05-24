//
//  IAVEncoder.swift
//  RxLeanCloudSwift
//
//  Created by WuJun on 24/05/2017.
//  Copyright © 2017 LeanCloud. All rights reserved.
//

import Foundation
public protocol IAVEncoder {
    func encode(value: Any) -> Any
}
