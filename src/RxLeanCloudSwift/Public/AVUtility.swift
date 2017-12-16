//
//  AVUtility.swift
//  RxLeanCloudSwift
//
//  Created by WuJun on 15/12/2017.
//  Copyright © 2017 LeanCloud. All rights reserved.
//

import Foundation

class AVUtility {

    static let mainQueue = DispatchQueue.main
    public static func asynchronize<Result>(_ task: @escaping () -> Result, _ queue: DispatchQueue, _ completion: @escaping (Result) -> Void) {
        queue.async {
            let result = task()
            mainQueue.async {
                completion(result)
            }
        }
    }
}
