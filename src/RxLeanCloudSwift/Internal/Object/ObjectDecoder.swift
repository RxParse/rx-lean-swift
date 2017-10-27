//
//  ObjectDecoder.swift
//  RxLeanCloudSwift
//
//  Created by WuJun on 24/05/2017.
//  Copyright © 2017 LeanCloud. All rights reserved.
//

import Foundation

public class ObjectDecoder: IObjectDecoder {

    public func decode(serverResult: [String: Any], decoder: IAVDecoder) -> IObjectState {
        let mutable = MutableObjectState()
        self.handlerSaveResult(state: mutable, serverResult: serverResult, decoder: decoder)
        return mutable as IObjectState
    }

    public func handlerSaveResult(state: MutableObjectState, serverResult: [String: Any], decoder: IAVDecoder) {

        var mutableServerResult = decoder.clone(dictionary: serverResult)

        if mutableServerResult["createdAt"] != nil {
            let dateString = mutableServerResult["createdAt"] as! String
            state.createdAt = RxAVCorePlugins.dateFormatter.date(from: dateString)

            mutableServerResult["createdAt"] = nil
        }
        if mutableServerResult["updatedAt"] != nil {
            let dateString = mutableServerResult["updatedAt"] as! String
            state.updatedAt = RxAVCorePlugins.dateFormatter.date(from: dateString)

            mutableServerResult["updatedAt"] = nil
        }
        if mutableServerResult["objectId"] != nil {
            state.objectId = mutableServerResult["objectId"] as? String
            mutableServerResult["objectId"] = nil
        }

        for (key, value) in mutableServerResult {
            state.serverData[key] = decoder.decode(value: value)
        }
    }
}
