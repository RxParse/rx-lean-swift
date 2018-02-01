//
//  RxAVQuery.swift
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
    var app: LeanCloudApp? { get set }
}

public protocol IAVQueryable {
    associatedtype AVQueryableType
    init(serverState: IObjectState)
    func retore(serverState: IObjectState) -> AVQueryableType
}

public protocol QueryableConvertible {
    associatedtype QueryableType
    func find() -> Observable<Array<QueryableType>>
}

public class RxAVQuery<TEntity>: IAVQuery, QueryableConvertible where TEntity: IAVQueryable {

    public func find() -> Observable<Array<TEntity>> {
        return RxAVQuery.queryController.find(query: self).map({ (serverStates) -> Array<TEntity> in
            return serverStates.map({ (serverState) -> TEntity in
                let entity = TEntity(serverState: serverState)
                return entity
            })
        })
    }

    public typealias QueryableType = TEntity
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
    public var app: LeanCloudApp?
    internal var _where: [String: Any] = [String: Any]()

    public init(className: String) {
        self.className = className
        self.app = RxAVClient.sharedInstance.getCurrentApp()
    }

    public func equalTo(key: String, value: Any) -> RxAVQuery {
        self._where[key] = self._encode(value: value)
        return self
    }

    public func notEqualTo(key: String, value: Any) -> RxAVQuery {
        return self._addCondition(key: key, condition: "$ne", value: value)
    }

    public func lessThan(key: String, value: Any) -> RxAVQuery {
        return self._addCondition(key: key, condition: "$lt", value: value)
    }

    public func lessThanOrEqualTo(key: String, value: Any) -> RxAVQuery {
        return self._addCondition(key: key, condition: "$lte", value: value)
    }

    public func greaterThan(key: String, value: Any) -> RxAVQuery {
        return self._addCondition(key: key, condition: "$gt", value: value)
    }

    public func greaterThanOrEqualTo(key: String, value: Any) -> RxAVQuery {
        return self._addCondition(key: key, condition: "$gte", value: value)
    }

    public func containedIn(key: String, value: Any) -> RxAVQuery {
        return self._addCondition(key: key, condition: "$in", value: value)
    }

    public func notContainedIn(key: String, value: Any) -> RxAVQuery {
        return self._addCondition(key: key, condition: "$nin", value: value)
    }

    public func containsAll(key: String, value: Any) -> RxAVQuery {
        return self._addCondition(key: key, condition: "$all", value: value)
    }

    public func exists(key: String) -> RxAVQuery {
        return self._addCondition(key: key, condition: "$exists", value: true)
    }

    public func doesNotExist(key: String) -> RxAVQuery {
        return self._addCondition(key: key, condition: "$exists", value: false)
    }

    public func contains(key: String, value: String) -> RxAVQuery {
        return self._addCondition(key: key, condition: "$regex", value: self.qoute(s: value))
    }

    public func startsWith(key: String, value: String) -> RxAVQuery {
        return self._addCondition(key: key, condition: "$gt", value: self.qoute(s: value))
    }

    public func endsWith(key: String, value: String) -> RxAVQuery {
        return self._addCondition(key: key, condition: "$gt", value: self.qoute(s: value))
    }

    public func ascending(keys: Array<String>) -> RxAVQuery {
        self.order = []
        return self.addAscending(keys: keys)
    }

    public func addAscending(keys: Array<String>) -> RxAVQuery {
        if self.order == nil {
            self.order = [String]()
        }
        keys.forEach { (key) in
            self.order?.append(key)
        }
        return self
    }

    public func descending(keys: Array<String>) -> RxAVQuery {
        self.order = []
        return self.addDescending(keys: keys)
    }

    public func addDescending(keys: Array<String>) -> RxAVQuery {
        if self.order == nil {
            self.order = [String]()
        }
        keys.forEach { (key) in
            self.order?.append("-" + key)
        }
        return self
    }

    public func include(keys: Array<String>) -> RxAVQuery {
        if self.include == nil {
            self.include = [String]()
        }
        keys.forEach { (key) in
            self.include?.append(key)
        }
        return self
    }

    public func select(keys: Array<String>) -> RxAVQuery {
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

    func _addCondition(key: String, condition: String, value: Any) -> RxAVQuery {
        if self._where[key] != nil || self._where[key] is String {
            self._where[key] = [String: Any]()
        }
        let encodedFilter = self._encode(value: value)
        let conditionMap = [condition: encodedFilter]
        self._where[key] = conditionMap
        return self
    }

    func _encode(value: Any) -> Any {
        return RxAVQuery._encoder.encode(value: value)
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
