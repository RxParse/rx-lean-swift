//
//  MutableObjectState.swift
//  RxLeanCloudSwift
//
//  Created by WuJun on 23/05/2017.
//  Copyright © 2017 LeanCloud. All rights reserved.
//

import Foundation

public class MutableObjectState: IObjectState {

    public var objectId: String? = nil
    public var isNew: Bool = true
    public var className: String = "DefaultAVObject"
    public var updatedAt: Date? = nil
    public var createdAt: Date? = nil
    public var app: RxAVApp? = nil
    public var serverData: [String: Any] = [String: Any]()

//    init(objectId: String?, isNew: Bool?, className: String?, updatedAt: Date?, createdAt: Date?, app: RxAVApp?, serverData: [String: Any]?) {
//        self.app = app!;
//        self.objectId = objectId
//        self.className = className!
//        self.updatedAt = updatedAt!
//        self.createdAt = createdAt!
//        self.serverData = serverData!
//        self.isNew = isNew!;
//    }

    public func apply(state: IObjectState) -> Void {
        self.app = state.app
        self.objectId = state.objectId
        self.isNew = state.isNew
        self.updatedAt = state.updatedAt
        self.createdAt = state.createdAt
        self.serverData = state.serverData
    }

    public func merge(state: IObjectState) -> Void {
        self.isNew = state.isNew
        self.objectId = state.objectId
        self.updatedAt = state.updatedAt
        if state.createdAt != nil {
            self.createdAt = state.createdAt
        }
    }

    public func containsKey(key: String) -> Bool {
        return serverData.containsKey(key: key)
    }

    public func mutatedClone(_ hook: (IObjectState) -> Void) -> IObjectState {
        let clone = self.mutableClone()
        hook(clone)
        return clone
    }

    public func mutableClone() -> IObjectState {
        let state = MutableObjectState()

        state.objectId = self.objectId
        state.isNew = self.isNew
        state.className = self.className
        state.updatedAt = self.updatedAt
        state.createdAt = self.createdAt
        state.app = self.app
        state.serverData = self.serverData

        return state
    }
}
