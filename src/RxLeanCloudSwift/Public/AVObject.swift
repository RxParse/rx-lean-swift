//
//  AVObject.swift
//  RxLeanCloudSwift
//
//  Created by WuJun on 22/05/2017.
//  Copyright © 2017 LeanCloud. All rights reserved.
//

import Foundation
import RxSwift

public protocol IAVObject {
    var objectId: String? { get }
    var className: String { get set }
    subscript (key: String) -> Any? { get set }
    var createdAt: Date? { get }
    var updatedAt: Date? { get }
}

public class AVObject: IAVObject {

    public init(className: String, app: AVApp) {
        self._state.className = className
        self._isDirty = true
        self._state.app = app
    }

    public convenience init(className: String) {
        let currentApp = AVClient.sharedInstance.getCurrentApp()
        self.init(className: className, app: currentApp)
    }

    public convenience init(className: String, objectId: String, app: AVApp?) {
        let _app = AVClient.sharedInstance.takeApp(app: app)
        self.init(className: className, app: _app)
        self.objectId = objectId
    }

    static var objectController: IObjectController {
        get {
            return AVCorePlugins.sharedInstance.objectController
        }
    }

    var _isNew: Bool = false
    var _isDirty: Bool = false
    var _state: MutableObjectState = MutableObjectState()

    var localEstimatedData: [String: Any] = [String: Any]()
    var currentOperations: [String: IAVFieldOperation] = [String: IAVFieldOperation]()

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
            return self.get(key: key)
        }
        set {
            self.set(key: key, value: newValue)
            //self.localEstimatedData[key] = newValue
        }
    }

    public func get(key: String) -> Any? {
        if self.localEstimatedData.containsKey(key: key) {
            if let value = self.localEstimatedData[key] {
                return value
            }
        }
        return self.getProperty(key: key)
    }

    public func set(key: String, value: Any?) {
        if value == nil {
            self.performOperation(key: key, operation: AVDeleteOperation.sharedInstance)
        } else {
            let valid = AVCorePlugins.sharedInstance.avEncoder.isValidType(value: value!)
            if valid {
                self.performOperation(key: key, operation: AVSetOperation(value: value!))
            }
        }
    }

    public func increase(key: String) {
        self.performOperation(key: key, operation: AVIncrementOperation(_amount: 1))
    }

    public func increase(key: String, amount: Int) {
        self.performOperation(key: key, operation: AVIncrementOperation(_amount: amount))
    }

    public func increase(key: String, amount: Double) {
        self.performOperation(key: key, operation: AVIncrementOperation(_amount: amount))
    }

    func performOperation(key: String, operation: IAVFieldOperation) {
        let oldValue = self.localEstimatedData.tryGetValue(key: key)
        let newValue = operation.apply(oldValue: oldValue, key: key)

        if newValue is AVDeleteToken {
            self.localEstimatedData[key] = newValue
        } else {
            self.localEstimatedData.removeValue(forKey: key)
        }

        let oldOperation = self.currentOperations.tryGetValue(key: key)
        let newOperation = operation.mergeWithPrevious(previous: oldOperation)
        self.currentOperations[key] = newOperation
        if self.currentOperations.count > 0 {
            self._isDirty = true
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

    public func save() -> Observable<AVObject> {
        var observableResult: Observable<AVObject> = Observable.from([self])

        if !self._isDirty {
            return observableResult
        }

        try! AVObject.recursionCollectDirtyChildren(root: self, warehouse: [AVObject](), seen: [AVObject](), seenNew: [AVObject]())

        let dirtyChildren = self.collectAllLeafNodes()

        if dirtyChildren.count > 0 {
            observableResult = self.batchSave(objArray: dirtyChildren).flatMap({ (batchSuccess) -> Observable<AVObject> in
                return self.save()
            })
        } else {
            observableResult = AVObject.objectController.save(state: self._state, operations: self.currentOperations).map { (serverState) -> AVObject in
                self.handlerSaved(serverState: serverState)
                return self
            }
        }
        return observableResult
    }

    public static func createWithoutData(classnName: String, objectId: String) -> AVObject {
        let objInstance = AVObject(className: classnName)
        objInstance.objectId = objectId
        return objInstance
    }

    func batchSave(objArray: Array<AVObject>) -> Observable<Bool> {
        let states = objArray.map { (obj) -> IObjectState in
            return obj._state
        }
        let operationss = objArray.map { (obj) -> [String: IAVFieldOperation] in
            return obj.currentOperations
        }
        return AVObject.objectController.batchSave(states: states, operationss: operationss, app: self._state.app!).map { (serverStateArray) -> Bool in
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
        self.rebuildlocalEstimatedData()
    }

    func rebuildlocalEstimatedData() {
        self.localEstimatedData = self._state.serverData
    }

    func collectDirtyChildren() -> [AVObject] {
        var dirtyChildren: [AVObject] = [AVObject]()
        for (_, value) in self.localEstimatedData {
            if value is AVObject {
                dirtyChildren.append(value as! AVObject)
            }
        }
        return dirtyChildren
    }

    enum AVObjectError: Error {
        case circularReference(reason: String)
    }

    func collectAllLeafNodes() -> [AVObject] {
        var leafNodes: Array<AVObject> = []
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

    static func recursionCollectDirtyChildren(root: AVObject, warehouse: Array<AVObject>, seen: Array<AVObject>, seenNew: Array<AVObject>) throws {
        var seen = seen
        var warehouse = warehouse

        let dirtyChildren = root.collectDirtyChildren()

        try dirtyChildren.forEach { (child) in
            var scopedSeenNew: Array<AVObject> = [AVObject]()
            if seenNew.contains(where: { (item) -> Bool in
                return item === child
            }) {
                throw AVObjectError.circularReference(reason: "Found a circular dependency while saving")
            }

            scopedSeenNew = scopedSeenNew + seenNew
            scopedSeenNew.append(child)

            if seen.contains(where: { (item) -> Bool in
                return item === child
            }) {
                return
            }

            seen.append(child)
            try AVObject.recursionCollectDirtyChildren(root: child, warehouse: warehouse, seen: seen, seenNew: scopedSeenNew)
            warehouse.append(child)
        }
    }

    func setProperty(key: String, value: Any) -> Void {
        self._state.serverData[key] = value
    }

    func getProperty(key: String) -> Any? {
        let contained = self._state.containsKey(key: key)
        if contained {
            let value = self._state.serverData[key]
            return value
        }
        return nil
    }
}

