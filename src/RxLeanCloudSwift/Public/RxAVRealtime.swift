//
//  RxAVRealtime.swift
//  RxLeanCloudSwift
//
//  Created by WuJun on 27/05/2017.
//  Copyright © 2017 LeanCloud. All rights reserved.
//

import Foundation
import RxSwift

public protocol IRxAVIMMessage {
    var conversationId: String { get set }
    var raw: String { get set }
    var id: String { get set }
    var timestamp: Double { get set }
    var from: String { get set }
    func deserialize(raw: String) -> Void
    func serialize() -> String
    func validate(raw: String) -> Bool
}

public class RxAVRealtime {
    public static let sharedInstance = RxAVRealtime(app: nil)
    public var onMessage: Observable<IRxAVIMMessage>?
    var app: RxAVApp? = nil
    var idSeed: Int = -65535;
    func cmdIdAutomation() -> Int {
        return self.idSeed + 1
    }
    public init(app: RxAVApp? = nil) {
        self.app = RxAVClient.sharedInstance.getCurrentApp()
    }

    public func connect(clientId: String) throws -> Observable<[String:Any]> {
        let cmdBody = [
            "cmd": "session",
            "op": "open",
            "appId": self.app?.appId,
            "peerId": clientId,
            "i": self.cmdIdAutomation(),
            "ua": "rx-lean-swift/\(RxAVClient.sharedInstance.getSDKVersion())"
        ] as [String: Any]
        return try RxAVWebSocket.sharedInstance.send(json: cmdBody)
    }

    public func connectWithUser(user: RxAVUser) throws -> Observable<[String:Any]> {
        return try self.connect(clientId: user.username)
    }
}
