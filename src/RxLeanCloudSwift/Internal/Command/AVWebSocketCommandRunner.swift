//
//  AVWebSocketCommandRunner.swift
//  RxLeanCloudSwift
//
//  Created by WuJun on 15/12/2017.
//  Copyright © 2017 LeanCloud. All rights reserved.
//

import Foundation
import RxSwift

public class AVWebSocketCommandRunner: IAVCommandRunner {
    var websocketClient: IWebSokcetClient
    init(websocketClient: IWebSokcetClient) {
        self.websocketClient = websocketClient
    }

    public func runRxCommand(command: AVCommand) -> Observable<AVCommandResponse> {
        return try! self.websocketClient.send(command: command)
    }

    public func runBatchRxCommands(commands: [AVCommand], app: LeanCloudApp) -> Observable<[AVCommandResponse]> {
        let rxBatchResponse = commands.map { (cmd) -> Observable<AVCommandResponse> in
            return self.runRxCommand(command: cmd)
        }

        return Observable.zip(rxBatchResponse)
    }


}

