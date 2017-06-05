//
//  RxAVObject.swift
//  RxLeanCloudSwift
//
//  Created by WuJun on 22/05/2017.
//  Copyright © 2017 LeanCloud. All rights reserved.
//

import Foundation
import RxSwift

public protocol IRxAVObject {
    var objectId: String? { get }
    var className: String { get set }
    subscript (key: String) -> Any? { get set }
    var createdAt: Date? { get }
    var updatedAt: Date? { get }
}

public protocol IRxRealmObject {
    
}

public class RxAVObject: IRxAVObject {

    static var objectController: IObjectController {
        get {
            return RxAVCorePlugins.sharedInstance.objectController
        }
    }

    var _isNew: Bool = false
    var _isDirty: Bool = false
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

    public internal(set) var objectId: String? {
        get {
            return self._state.objectId
        }
        set {
            self._state.objectId = newValue
        }
    }

    public subscript (key: String) -> Any? {
        get {
            return self.estimatedData[key]
        }
        set {
            self.estimatedData[key] = newValue
        }
    }

    public var createdAt: Date? {
        get {
            return self._state.createdAt
        }
    }

    public var updatedAt: Date? {
        get {
            return self._state.updatedAt
        }
    }

    public init(className: String) {
        self._state.className = className
        self._isDirty = true
        self._state.app = RxAVClient.sharedInstance.getCurrentApp()
    }

    public func save() -> Observable<RxAVObject> {
        var observableResult: Observable<RxAVObject> = Observable.from([self])

        if !self._isDirty {
            return observableResult
        }

        try! RxAVObject.recursionCollectDirtyChildren(root: self, warehouse: [RxAVObject](), seen: [RxAVObject](), seenNew: [RxAVObject]())

        let dirtyChildren = self.collectAllLeafNodes()

        if dirtyChildren.count > 0 {
            observableResult = self.batchSave(objArray: dirtyChildren).flatMap({ (batchSuccess) -> Observable<RxAVObject> in
                return self.save()
            })
        } else {
            observableResult = RxAVObject.objectController.save(state: self._state, estimatedData: self.estimatedData).map { (serverState) -> RxAVObject in
                self.handlerSaved(serverState: serverState)
                return self
            }
        }
        return observableResult
    }

    public static func createWithoutData(classnName: String, objectId: String) -> RxAVObject {
        let objInstance = RxAVObject(className: classnName)
        objInstance.objectId = objectId
        return objInstance
    }

    func batchSave(objArray: Array<RxAVObject>) -> Observable<Bool> {
        let states = objArray.map { (obj) -> IObjectState in
            return obj._state
        }
        let estimatedDatas = objArray.map { (obj) -> [String: Any] in
            return obj.estimatedData
        }
        return RxAVObject.objectController.batchSave(states: states, estimatedDatas: estimatedDatas, app: self._state.app!).map { (serverStateArray) -> Bool in
            let pair = zip(objArray, serverStateArray)
            pair.forEach({ (obj, state) in
                obj.handlerSaved(serverState: state)
            })
            return true
        }
    }

    func handlerSaved(serverState: IObjectState) -> Void {
        self._state.merge(state: serverState)
        self._isDirty = false
    }

    func handleFetchResult(serverState: IObjectState) -> Void {
        self._state.apply(state: serverState)
        self._isDirty = false
        self._isNew = false
        self.rebuildEstimatedData()
    }
    func rebuildEstimatedData() {
        self.estimatedData = self._state.serverData
    }
    func collectDirtyChildren() -> [RxAVObject] {
        var dirtyChildren: [RxAVObject] = [RxAVObject]()
        for (_, value) in self.estimatedData {
            if value is RxAVObject {
                dirtyChildren.append(value as! RxAVObject)
            }
        }
        return dirtyChildren
    }
    enum RxAVObjectError: Error {
        case circularReference(reason: String)
    }

    func collectAllLeafNodes() -> [RxAVObject] {
        var leafNodes: Array<RxAVObject> = []
        let dirtyChildren = self.collectDirtyChildren()

        dirtyChildren.forEach { (child) in
            let childLeafNodes = child.collectAllLeafNodes()
            if childLeafNodes.count == 0 {
                if (child._isDirty) {
                    leafNodes.append(child)
                }
            } else {
                leafNodes = leafNodes + childLeafNodes
            }
        }

        return leafNodes
    }

    static func recursionCollectDirtyChildren(root: RxAVObject, warehouse: Array<RxAVObject>, seen: Array<RxAVObject>, seenNew: Array<RxAVObject>) throws {
        var seen = seen
        var warehouse = warehouse

        let dirtyChildren = root.collectDirtyChildren()

        try dirtyChildren.forEach { (child) in
            var scopedSeenNew: Array<RxAVObject> = [RxAVObject]()
            if seenNew.contains(where: { (item) -> Bool in
                return item === child
            }) {
                throw RxAVObjectError.circularReference(reason: "Found a circular dependency while saving")
            }

            scopedSeenNew = scopedSeenNew + seenNew
            scopedSeenNew.append(child)

            if seen.contains(where: { (item) -> Bool in
                return item === child
            }) {
                return
            }

            seen.append(child)
            try RxAVObject.recursionCollectDirtyChildren(root: child, warehouse: warehouse, seen: seen, seenNew: scopedSeenNew)
            warehouse.append(child)
        }
    }
    func setProperty(key: String, value: Any) -> Void {
        self._state.serverData[key] = value
    }
    func getProperty(key: String) -> Any? {
        if self._state.containsKey(key: key) {
            return self._state.serverData[key]
        }
        return nil
    }
}
