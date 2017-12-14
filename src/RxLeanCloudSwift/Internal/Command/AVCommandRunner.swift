//
//  AVCommandRunner.swift
//  RxLeanCloudSwift
//
//  Created by WuJun on 22/05/2017.
//  Copyright © 2017 LeanCloud. All rights reserved.
//

import Foundation
import RxSwift

public class AVCommandRunner: IAVCommandRunner {

    var httpClient: IRxHttpClient
    var websocketClient: IRxWebSokcetClient
    init(httpClient: IRxHttpClient, websocketClient: IRxWebSokcetClient) {
        self.httpClient = httpClient
        self.websocketClient = websocketClient
    }


    public func runRxCommand(command: AVCommand) -> Observable<AVCommandResponse> {
        return self.httpClient.execute(httpRequest: command).map { (httpResponse) -> AVCommandResponse in
            let avResponse = AVCommandResponse(statusCode: httpResponse.satusCode, data: httpResponse.data)
            return avResponse
        }
    }

    enum HttpError: Error {
        case batchRequestNotCompleted(result: String)
    }
    public func runBatchRxCommands(commands: [AVCommand], app: AVApp) -> Observable<[AVCommandResponse]> {

        let batchSize = commands.count

        let encodedRequests = commands.map { (cmd) -> [String: Any] in
            var reqBody: [String: Any] = ["method": cmd.method, "path": "\(app.apiVersion)\(cmd.realtiveUrl)"]
            if cmd.data != nil {
                reqBody["body"] = cmd.data
            }
            return reqBody
        }

        let batchRequest = AVCommand(
            relativeUrl: "/batch",
            method: "POST",
            data: ["requests": encodedRequests],
            app: app
        )

        return self.runRxCommand(command: batchRequest).map({ (batchResponse) -> [AVCommandResponse] in
            var rtn: Array<AVCommandResponse> = [AVCommandResponse]()
            let results = batchResponse.jsonBody
            let batchResults = results!["results"] as! Array<Any>
            let resultLength = batchResults.count

            if resultLength != batchSize {
                throw HttpError.batchRequestNotCompleted(result: "Batch command result count expected: \(batchSize)  but was: \(resultLength)")
            }

            rtn = batchResults.map({ (result) -> AVCommandResponse in
                if result is [String: Any] {
                    let subBody = result as! [String: Any]
                    if subBody["success"] != nil {
                        return AVCommandResponse(statusCode: 200, jsonBody: subBody["success"] as? [String: Any])
                    }
                }
                return AVCommandResponse(statusCode: 400, jsonBody: ["failed": "batchError"])
            })

            return rtn
        })
    }
}
