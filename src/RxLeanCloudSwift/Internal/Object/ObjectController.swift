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
        let mutableState = MutableObjectState()
        mutableState.apply(state: state)
        mutableState.removeReadOnlyFields()
        mutableState.removeRelationFields()

        var mutableEncoded = [String: Any]()

        for (key, value) in estimatedData {
            mutableEncoded[key] = RxAVCorePlugins.sharedInstance.avEncoder.encode(value: value)
        }

        let realtiveUrl = mutableState.objectId == nil ? "/classes/\(state.className)" : "/classes/\(state.className)/\(state.objectId!)"
        let url = mutableState.app!.getUrl(relativeUrl: realtiveUrl)
        let headers = mutableState.app!.getHeaders()
        let cmd = AVCommand(method: mutableState.objectId == nil ? "POST" : "PUT", url: url, headers: headers, data: mutableEncoded)

        print(cmd.url, cmd.headers, cmd.method, cmd.data)

        return self.commandRunner.runRxCommand(command: cmd).map({ (avResponse) -> IObjectState in
            var serverState = RxAVCorePlugins.sharedInstance.objectDecoder.decode(serverResult: avResponse.body!, decoder: RxAVCorePlugins.sharedInstance.avDecoder)
            serverState = serverState.mutatedClone({ (state) in
                serverState.isNew = avResponse.satusCode == 200
            })
            return serverState
        })
    }


}
