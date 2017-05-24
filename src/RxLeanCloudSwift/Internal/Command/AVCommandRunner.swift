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
    init(httpClient: IRxHttpClient) {
        self.httpClient = httpClient
    }
    
    public func runRxCommand(command: AVCommand) -> Observable<AVCommandResponse>{
        return self.httpClient.execute(httpRequest: command).map { (httpResponse) -> AVCommandResponse in
            let avResponse = AVCommandResponse(statusCode: httpResponse.satusCode, body:httpResponse.body)
            return avResponse
        }
    }
}
