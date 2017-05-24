//
//  RxAVObject.swift
//  RxLeanCloudSwift
//
//  Created by WuJun on 22/05/2017.
//  Copyright © 2017 LeanCloud. All rights reserved.
//

import Foundation
import RxSwift

public class RxAVObject {

    static var objectController: IObjectController {
        get {
            return RxAVCorePlugins.sharedInstance.objectController
        }
    }
    var _isNew: Bool = true
    var _isDirty: Bool = true
    var _state: MutableObjectState = MutableObjectState()

    var estimatedData: [String: Any] = [String: Any]()

    public var className: String {
        get {
            return self._state.className
        }
        set {
            self._state.className = newValue
        }
    }

    public var objectId: String {
        get {
            return self._state.objectId!
        }
    }

    var isDirty: Bool = true

    public init(className: String) {
        self._state.className = className
        self._state.app = RxAVClient.sharedInstance.getCurrentApp()
    }

    public subscript (key: String) -> Any? {
        get {
            return self.estimatedData[key]
        }
        set {
            self.estimatedData[key] = newValue
        }
    }

    public func save() -> Observable<RxAVObject> {
        return RxAVObject.objectController.save(state: self._state, estimatedData: self.estimatedData).map { (serverState) -> RxAVObject in
            self.handlerSaved(serverState: serverState)
            return self
        }
    }

    func handlerSaved(serverState: IObjectState) -> Void {
        self._state.apply(state: serverState)
        self.isDirty = false
    }
}
