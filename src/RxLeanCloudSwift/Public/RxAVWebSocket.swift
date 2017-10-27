//
//  RxAVConnection.swift
//  RxLeanCloudSwift
//
//  Created by WuJun on 27/05/2017.
//  Copyright © 2017 LeanCloud. All rights reserved.
//

import Foundation
import RxSwift

public class RxAVWebSocket {

    public static var sharedInstance: RxAVWebSocket = RxAVWebSocket(app: nil)

    public var rxWebSocketClient: IRxWebSokcetClient {
        get {
            return RxAVCorePlugins.sharedInstance.webSocketClient
        }
    }
    
    var app: RxAVApp? = nil
    var pushRouterState: [String: Any]?
    public init(app: RxAVApp? = nil) {
        self.app = RxAVClient.sharedInstance.getCurrentApp()
    }

    public func open() -> Observable<Bool> {
        if self.app?.wss != nil {
            return self.rxWebSocketClient.open(url: (app?.wss)!, subprotocol: nil)
        }
        let pushRouter = self.app?.getPushRouterUrl()

        return RxAVClient.sharedInstance.httpRequest(url: pushRouter!, method: nil, headers: nil, data: nil).flatMap({ (response) -> Observable<Bool> in
            self.pushRouterState = response.jsonBody
            if (self.pushRouterState?.containsKey(key: "server"))! {
                let wss = self.pushRouterState?["server"] as! String
                return self.rxWebSocketClient.open(url: wss, subprotocol: ["lc.json.3"])
            }
            return Observable.from([false])
        })
    }

    public func send(json: [String: Any]) throws -> Observable<[String:Any]> {
        let cmd = AVCommand.create(json: json, app: self.app!)
        return try self.rxWebSocketClient.send(command: cmd).map({ (avResponse) -> [String: Any] in
            return avResponse.jsonBody!
        })
    }

}
