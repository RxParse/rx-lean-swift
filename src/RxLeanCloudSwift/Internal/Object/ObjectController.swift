//
//  ObjectController.swift
//  RxLeanCloudSwift
//
//  Created by WuJun on 23/05/2017.
//  Copyright © 2017 LeanCloud. All rights reserved.
//

import Foundation
import RxSwift

public class ObjectController: IObjectController {

    var commandRunner: IAVCommandRunner
    init(commandRunner: IAVCommandRunner) {
        self.commandRunner = commandRunner
    }

    public func save(state: IObjectState, estimatedData: [String: Any]) -> Observable<IObjectState> {

        let cmd = self.packRequest(state: state, estimatedData: estimatedData)
        return self.commandRunner.runRxCommand(command: cmd).map({ (avResponse) -> IObjectState in
            return self.unpackResponse(avResponse: avResponse)
        })
    }

    public func batchSave(states: [IObjectState], estimatedDatas: Array<[String: Any]>, app: RxAVApp) -> Observable<[IObjectState]> {

        let pair = zip(states, estimatedDatas)
        let cmds = pair.map { (seKV) -> AVCommand in
            return packRequest(state: seKV.0, estimatedData: seKV.1)
        }

        return self.commandRunner.runBatchRxCommands(commands: cmds, app: app).map({ (avResponses) -> [IObjectState] in
            return avResponses.map({ (avResponse) -> IObjectState in
                return self.unpackResponse(avResponse: avResponse)
            })
        })
    }

    func packRequest(state: IObjectState, estimatedData: [String: Any]) -> AVCommand {
        var mutableState = state.mutatedClone { (state) in
            
        }

        mutableState = self.removeReadOnlyFields(state: mutableState)
        mutableState = self.removeRelationFields(state: mutableState)

        var mutableEncoded = [String: Any]()

        for (key, value) in estimatedData {
            mutableEncoded[key] = RxAVCorePlugins.sharedInstance.avEncoder.encode(value: value)
        }

        let realtiveUrl = mutableState.objectId == nil ? "/classes/\(mutableState.className)" : "/classes/\(mutableState.className)/\(mutableState.objectId!)"
        return AVCommand(relativeUrl: realtiveUrl, method: mutableState.objectId == nil ? "POST" : "PUT", data: mutableEncoded, app: mutableState.app!)
    }

   public func unpackResponse(avResponse: AVCommandResponse) -> IObjectState {
        var serverState = RxAVCorePlugins.sharedInstance.objectDecoder.decode(serverResult: avResponse.body! as! [String: Any], decoder: RxAVCorePlugins.sharedInstance.avDecoder)
        serverState = serverState.mutatedClone({ (state) in
            serverState.isNew = avResponse.satusCode == 200
        })
        return serverState
    }

    public func removeReadOnlyFields(state: IObjectState) -> IObjectState {
        var state = state
        if state.containsKey(key: "objectId") {
            state.serverData.removeValue(forKey: "objectId")
        } else if state.containsKey(key: "createdAt") {
            state.serverData.removeValue(forKey: "createdAt")
        } else if state.containsKey(key: "updatedAt") {
            state.serverData.removeValue(forKey: "updatedAt")
        }
        return state
    }

    public func removeRelationFields(state: IObjectState) -> IObjectState {
        var state = state
        for (key, value) in state.serverData {
            if value is [String: Any] {
                var vMap = value as! [String: Any]
                if vMap["__type"] != nil {
                    if (vMap["__type"] as! String) == "Relation" {
                        state.serverData.removeValue(forKey: key)
                    }
                }
            }
        }
        return state
    }
}
