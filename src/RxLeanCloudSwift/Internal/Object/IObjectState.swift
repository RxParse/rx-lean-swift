//
//  IObjectState.swift
//  RxLeanCloudSwift
//
//  Created by WuJun on 23/05/2017.
//  Copyright © 2017 LeanCloud. All rights reserved.
//

import Foundation

public protocol IObjectState {
    var isNew: Bool { get set }
    var className: String { get set }
    var objectId: String? { get set }
    var updatedAt: Date? { get set }
    var createdAt: Date? { get set }
    var app: RxAVApp? { get set }
    var serverData: [String: Any] { get set }
    func containsKey(key: String) -> Bool
    func mutatedClone(_ hook: (_ source: IObjectState) -> Void) -> IObjectState
}
