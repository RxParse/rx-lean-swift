//
//  IRxWebScoketClient.swift
//  RxLeanCloudSwift
//
//  Created by WuJun on 27/05/2017.
//  Copyright © 2017 LeanCloud. All rights reserved.
//

import Foundation
import RxSwift

public protocol IWebSokcetClient {

    func open(url: String, subprotocol: [String]?) -> Observable<Bool>

    func close() -> Observable<Bool>

    func send(command: AVCommand) throws -> Observable<AVCommandResponse>

    var onMessage: Observable<AVCommandResponse> { get set }

    var onState: Observable<Int> { get set }

//    var state: Int { get }
}
