//
//  IJson.swift
//  RxLeanCloudSwift
//
//  Created by WuJun on 27/05/2017.
//  Copyright © 2017 LeanCloud. All rights reserved.
//

import Foundation

public protocol IJSON {
    func parse(input: String) -> Any
    func encode(obj: Any) -> String
}
