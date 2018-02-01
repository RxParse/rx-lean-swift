//
//  AVRelationOperation.swift
//  RxLeanCloudSwift
//
//  Created by WuJun on 25/12/2017.
//  Copyright © 2017 LeanCloud. All rights reserved.
//

import Foundation

internal class AVRelationOperation: IAVFieldOperation {

    public var adds: Set<String> = [];
    public var removes: Set<String> = [];
    var targetClassName = ""

    init(adds: Array<String>, removes: Array<String>, targetClassName: String) {
        self.targetClassName = targetClassName
        self.adds = Set(adds)
        self.removes = Set(removes)
    }

    func encode() -> Any {
        let adds = self.adds.map { (id) -> RxAVObject in
            return RxAVObject.createWithoutData(classnName: self.targetClassName, objectId: id)
        }

        let removes = self.removes.map { (id) -> RxAVObject in
            return RxAVObject.createWithoutData(classnName: self.targetClassName, objectId: id)
        }
        let addDict = adds.count == 0 ? nil : ["__op": "AddRelation", "objects": adds]
        let removeDict = removes.count == 0 ? nil : ["__op": "RemoveRelation", "objects": removes]

        if let ad = addDict, let rd = removeDict {
            return ["__op": "Batch", "ops": [ad, rd]]
        }
        return addDict == nil ? removeDict as Any: addDict as Any
    }

    func mergeWithPrevious(previous: IAVFieldOperation?) -> IAVFieldOperation {
        if previous == nil {
            return self
        }
        if let _previous = previous {
            if _previous is AVDeleteOperation {
                return _previous
            }
            if _previous is AVRelationOperation {
                let other = _previous as! AVRelationOperation
                let newAdd = self.adds.union(other.adds)
                let newRemove = self.removes.union(other.removes)
                return AVRelationOperation(adds: Array(newAdd), removes: Array(newRemove), targetClassName: self.targetClassName)
            }
        }
        return self
    }

    func apply(oldValue: Any?, key: String) -> Any {
        if self.adds.count == 0 && self.removes.count == 0 {

        }
        if let _oldValue = oldValue {
            if _oldValue is AVRelation {
                let _o = _oldValue as! AVRelation
                return _o
            }
        }
        return AVRelation(parent: nil, key: key, targetClassName: self.targetClassName)
    }
}

internal class AVRelation<T>: IJsonConvertible where T: RxAVObject {

    func ToJSON() -> [String: Any] {
        return ["__type": "Relation", "className": self.targetClassName]
    }

    var parent: RxAVObject?
    var key: String
    var targetClassName: String

    init(parent: RxAVObject?, key: String, targetClassName: String) {
        self.key = key
        self.parent = parent
        self.targetClassName = targetClassName
    }

    public func add(obj: T) {
        let change = AVRelationOperation(adds: [obj.objectId!], removes: [], targetClassName: obj.className)
        parent?.performOperation(key: self.key, operation: change)
        self.targetClassName = obj.className
    }

    public func remove(obj: T) {
        let change = AVRelationOperation(adds: [], removes: [obj.objectId!], targetClassName: obj.className)
        parent?.performOperation(key: self.key, operation: change)
        self.targetClassName = obj.className
    }
}
