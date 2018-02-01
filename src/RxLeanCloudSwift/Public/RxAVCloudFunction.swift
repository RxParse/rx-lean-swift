//
//  RxAVCloudFunction.swift
//  RxLeanCloudSwift
//
//  Created by WuJun on 28/10/2017.
//  Copyright © 2017 LeanCloud. All rights reserved.
//

import Foundation
import RxSwift

/*
 * LeanEngine
 */
public class RxAVCloudFunction {
    public static func callCloudFuntion(functionName: String, payload: [String: Any]?, app: LeanCloudApp?) -> Observable<[String:Any]?> {
        let cmd = AVCommand(relativeUrl: "/functions/\(functionName)", method: "POST", data: payload, app: app)
        return RxAVClient.sharedInstance.runCommand(cmd: cmd).map({ (avResponse) -> [String: Any]? in
            return avResponse.jsonBody
        })
    }
    var functionName: String
    public var parameters: [String: Any]?
    
    public init(functionName: String) {
        self.functionName = functionName
    }
    
    public func call() -> Observable<[String:Any]?> {
        let app = RxAVClient.sharedInstance.takeApp(app: nil)
        let cmd = AVCommand(relativeUrl: "/functions/\(self.functionName)", method: "POST", data: self.parameters, app: app)
        return RxAVClient.sharedInstance.runCommand(cmd: cmd).map({ (avResponse) -> [String: Any]? in
            return avResponse.jsonBody
        })
    }
}

public protocol RxAVRPCFunctionConvertible: class {
    associatedtype ParameterType
    associatedtype ResultType
    func encode(entity: ParameterType) -> [String: Any]
    func decode(resultDictionary: [String: Any]) -> ResultType
}

public protocol RxAVRPCFunction {
    associatedtype AnyProcessor: RxAVRPCFunctionConvertible
    var processor: AnyProcessor { get set }
    var functionName: String { get set }
}

extension RxAVRPCFunction {
    public func execute(parameter: Self.AnyProcessor.ParameterType) -> Observable<Self.AnyProcessor.ResultType> {
        let data = self.processor.encode(entity: parameter)
        let app = RxAVClient.sharedInstance.takeApp(app: nil)
        let cmd = AVCommand(relativeUrl: "/call/\(self.functionName)", method: "POST", data: data, app: app)
        return RxAVClient.sharedInstance.runCommand(cmd: cmd).map({ (avResponse) -> Self.AnyProcessor.ResultType in
            return self.processor.decode(resultDictionary: avResponse.jsonBody!)
        })
    }
}
