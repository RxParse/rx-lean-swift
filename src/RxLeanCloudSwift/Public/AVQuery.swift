//
//  AVQuery.swift
//  RxLeanCloudSwift
//
//  Created by WuJun on 26/05/2017.
//  Copyright © 2017 LeanCloud. All rights reserved.
//

import Foundation
import RxSwift

public protocol IAVQuery {
    var condition: [String: Any] { get }
    var className: String? { get set }
    var relativeUrl: String? { get set }
    var skip: Int { get set }
    var limit: Int { get set }
    var include: [String]? { get set }
    var order: [String]? { get set }
    var select: [String]? { get set }
    var app: AVApp? { get set }
}

public class AVQuery: IAVQuery {

    public var condition: [String: Any] {
        get {
            return self._where
        }
    }

    public var className: String?
    public var relativeUrl: String?
    public var skip: Int = 0
    public var limit: Int = 20
    public var include: [String]?
    public var select: [String]?
    public var order: [String]?
    public var app: AVApp?
    internal var _where: [String: Any] = [String: Any]()

    public init(className: String) {
        self.className = className
        self.app = AVClient.sharedInstance.getCurrentApp()
    }

    public func find() -> Observable<Array<IAVObject>> {
        return AVQuery.queryController.find(query: self).map({ (serverStates) -> Array<IAVObject> in
            return serverStates.map({ (serverState) -> IAVObject in
                let rxObject = AVObject(className: self.className!)
                rxObject.handleFetchResult(serverState: serverState)
                return rxObject as IAVObject
            })
        })
    }

    public func equalTo(key: String, value: Any) -> AVQuery {
        self._where[key] = self._encode(value: value)
        return self
    }

    public func notEqualTo(key: String, value: Any) -> AVQuery {
        return self._addCondition(key: key, condition: "$ne", value: value)
    }

    public func lessThan(key: String, value: Any) -> AVQuery {
        return self._addCondition(key: key, condition: "$lt", value: value)
    }

    public func lessThanOrEqualTo(key: String, value: Any) -> AVQuery {
        return self._addCondition(key: key, condition: "$lte", value: value)
    }

    public func greaterThan(key: String, value: Any) -> AVQuery {
        return self._addCondition(key: key, condition: "$gt", value: value)
    }

    public func greaterThanOrEqualTo(key: String, value: Any) -> AVQuery {
        return self._addCondition(key: key, condition: "$gte", value: value)
    }
    
    public func containedIn(key: String, value: Any) -> AVQuery {
        return self._addCondition(key: key, condition: "$in", value: value)
    }
    
    public func notContainedIn(key: String, value: Any) -> AVQuery {
        return self._addCondition(key: key, condition: "$nin", value: value)
    }
    
    public func containsAll(key: String, value: Any) -> AVQuery {
        return self._addCondition(key: key, condition: "$all", value: value)
    }
    
    public func exists(key: String) -> AVQuery {
        return self._addCondition(key: key, condition: "$exists", value: true)
    }
    
    public func doesNotExist(key: String) -> AVQuery {
        return self._addCondition(key: key, condition: "$exists", value: false)
    }
    
    public func contains(key: String, value: String) -> AVQuery {
        return self._addCondition(key: key, condition: "$regex", value: self.qoute(s: value))
    }
    
    public func startsWith(key: String, value: String) -> AVQuery {
        return self._addCondition(key: key, condition: "$gt", value: self.qoute(s: value))
    }
    
    public func endsWith(key: String, value: String) -> AVQuery {
        return self._addCondition(key: key, condition: "$gt", value: self.qoute(s: value))
    }

    public func ascending(keys: Array<String>) -> AVQuery {
        self.order = []
        return self.addAscending(keys: keys)
    }
    
    public func addAscending(keys: Array<String>) -> AVQuery {
        if self.order == nil {
            self.order = [String]()
        }
        keys.forEach { (key) in
            self.order?.append(key)
        }
        return self
    }

    public func descending(keys: Array<String>) -> AVQuery {
        self.order = []
        return self.addDescending(keys: keys)
    }
    
    public func addDescending(keys: Array<String>) -> AVQuery {
        if self.order == nil {
            self.order = [String]()
        }
        keys.forEach { (key) in
            self.order?.append("-" + key)
        }
        return self
    }

    public func include(keys: Array<String>) -> AVQuery {
        if self.include == nil {
            self.include = [String]()
        }
        keys.forEach { (key) in
            self.include?.append(key)
        }
        return self
    }

    public func select(keys: Array<String>) -> AVQuery {
        if self.select == nil {
            self.select = [String]()
        }
        keys.forEach { (key) in
            self.select?.append(key)
        }
        return self
    }

    func qoute(s: String) -> String {
        return "\\Q" + s.replacingOccurrences(of: "\\E", with: "\\E\\\\E\\Q") + "\\E"
    }
    
    func _addCondition(key: String, condition: String, value: Any) -> AVQuery {
        if self._where[key] != nil || self._where[key] is String {
            self._where[key] = [String: Any]()
        }
        let encodedFilter = self._encode(value: value)
        let conditionMap = [condition: encodedFilter]
        self._where[key] = conditionMap
        return self
    }

    func _encode(value: Any) -> Any {
        return AVQuery._encoder.encode(value: value)
    }
    
    static var _encoder: IAVEncoder {
        get {
            return AVCorePlugins.sharedInstance.avEncoder
        }
    }

    static var queryController: IQueryController {
        get {
            return AVCorePlugins.sharedInstance.queryController
        }
    }

}
