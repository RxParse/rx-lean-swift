//
//  RxExtensions.swift
//  RxLeanCloudSwift
//
//  Created by WuJun on 15/12/2017.
//  Copyright © 2017 LeanCloud. All rights reserved.
//

import Foundation
import RxSwift


public protocol AVRxCallbackConvertible {
    associatedtype ResultType
    func onExecuted(completion: @escaping (ResultType) -> Void, error: @escaping (Error) -> Void) -> Void
}

public protocol AVRxEventConvertible {
    associatedtype EventArgsType
    func onEventInvoked(received: @escaping (EventArgsType) -> Void) -> Void
}

extension Observable: AVRxCallbackConvertible {
    public typealias ResultType = E

    public func onExecuted(completion: @escaping (Element) -> Void, error: @escaping (Error) -> Void) {

         _ = self.single().subscribe(onNext: { (resultElement) in
            completion(resultElement)
        }, onError: { (er) in
            error(er)
        }, onCompleted: {
        }) {
            print("onExecuted subscription disposed.")
        }
    }
}

extension Observable: AVRxEventConvertible {
    
    public func onEventInvoked(received: @escaping (Element) -> Void) {
        _ = self.subscribe(onNext: { (argsType) in
            received(argsType)
        }, onError: { (_) in

        }, onCompleted: {

        }) {

        }
    }

    public typealias EventArgsType = E
}


