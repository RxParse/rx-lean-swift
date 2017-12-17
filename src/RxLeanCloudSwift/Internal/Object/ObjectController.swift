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

    var httpCommandRunner: IAVCommandRunner
    init(httpCommandRunner: IAVCommandRunner) {
        self.httpCommandRunner = httpCommandRunner
    }

    public func save(state: IObjectState, operations: [String: IAVFieldOperation]) -> Observable<IObjectState> {

        let cmd = self.packRequest(state: state, operations: operations)

        return self.httpCommandRunner.runRxCommand(command: cmd).map({ (avResponse) -> IObjectState in
            return self.unpackResponse(avResponse: avResponse)
        })
    }

    public func batchSave(states: [IObjectState], operationss: Array<[String: IAVFieldOperation]>, app: AVApp) -> Observable<[IObjectState]> {

        let pair = zip(states, operationss)
        let cmds = pair.map { (seKV) -> AVCommand in
            return packRequest(state: seKV.0, operations: seKV.1)
        }

        return self.httpCommandRunner.runBatchRxCommands(commands: cmds, app: app).map({ (avResponses) -> [IObjectState] in
            return avResponses.map({ (avResponse) -> IObjectState in
                return self.unpackResponse(avResponse: avResponse)
            })
        })
    }

    public func delete(state: IObjectState, sessionToken: String?) -> Observable<Bool> {
        let cmd = AVCommand(relativeUrl: "/classes/\(state.className)/\(String(describing: state.objectId))", method: "Delete", data: nil, app: state.app)
        cmd.apiSessionToken = sessionToken
        return self.httpCommandRunner.runRxCommand(command: cmd).map({ (avResponse) -> Bool in
            return avResponse.satusCode == 200
        })
    }

    public func fetch(state: IObjectState, queryString: [String: Any]) -> Observable<IObjectState> {
        let _queryString = AVCorePlugins.sharedInstance.queryController.buildQueryString(parameters: queryString)
        let realtiveUrl = "/classes/\(state.className)/\(state.objectId!)?\(_queryString)"
        let cmd = AVCommand(relativeUrl: realtiveUrl, method: "GET", data: nil, app: state.app!)

        return self.httpCommandRunner.runRxCommand(command: cmd).map({ (avResponse) -> IObjectState in
            return self.unpackResponse(avResponse: avResponse)
        })
    }

    public func packRequest(state: IObjectState, operations: [String: IAVFieldOperation]) -> AVCommand {
        var mutableState = state.mutatedClone { (state) in

        }

        mutableState = self.removeReadOnlyFields(state: mutableState)
        mutableState = self.removeRelationFields(state: mutableState)

        var mutableEncoded: [String: Any]? = nil
        if operations.count > 0 {
            mutableEncoded = [String: Any]()
            for (key, value) in operations {
                mutableEncoded![key] = AVCorePlugins.sharedInstance.avEncoder.encode(value: value)
            }
        }

        let realtiveUrl = mutableState.objectId == nil ? "/classes/\(mutableState.className)" : "/classes/\(mutableState.className)/\(mutableState.objectId!)"
        return AVCommand(relativeUrl: realtiveUrl, method: mutableState.objectId == nil ? "POST" : "PUT", data: mutableEncoded, app: mutableState.app!)
    }

    public func unpackResponse(avResponse: AVCommandResponse) -> IObjectState {
        var serverState = AVCorePlugins.sharedInstance.objectDecoder.decode(serverResult: avResponse.jsonBody!, decoder: AVCorePlugins.sharedInstance.avDecoder)
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

