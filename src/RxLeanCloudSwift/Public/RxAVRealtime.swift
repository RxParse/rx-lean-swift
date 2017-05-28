//
//  RxAVRealtime.swift
//  RxLeanCloudSwift
//
//  Created by WuJun on 27/05/2017.
//  Copyright © 2017 LeanCloud. All rights reserved.
//

import Foundation
import RxSwift

public protocol IAVIMMessage {
    var conversationId: String { get set }
    var raw: String { get set }
    var id: String { get set }
    var timestamp: Double { get set }
    var from: String { get set }
    func deserialize(raw: String) -> Void
    func serialize() -> String
    func validate(raw: String) -> Bool
}

public struct AVIMTextMessage {

}

public struct AVIMMessageSendOptions {
    var clientId: String
    var conversationId: String
    var message: IAVIMMessage
    var transient: Bool
    var receipt: Bool
    var priority: Int
    var pushData: Any
}

public struct AVIMSignature {
    var noce: String
    var signature: String
    var timestamp: Double
}

public protocol IAVIMConversation {
    var conversationId: String { get set }
    var creator: String { get set }
    var name: String { get set }
    var members: [String] { get set }
    var transient: Bool { get set }
    var unique: Bool { get set }
    var attributes: [String: Any] { get set }
}

public struct AVIMConversation: IAVIMConversation {

    public init(conversationId: String? = nil, name: String? = nil, members: [String]? = nil, creator: String? = nil, attributes: [String: Any]? = nil, unique: Bool? = true, transient: Bool? = false) {

        self.creator = creator == nil ? "" : creator!
        self.conversationId = creator == nil ? "" : creator!
        self.name = name == nil ? "" : name!
        self.members = members == nil ? [String]() : members!
        self.attributes = attributes == nil ? [String: Any]() : attributes!
        self.unique = unique == nil ? true : unique!
        self.transient = transient == nil ? true : transient!

    }
    public var attributes: [String: Any]

    public var unique: Bool

    public var members: [String]

    public var transient: Bool

    public var creator: String

    public var name: String

    public var conversationId: String
}

public struct AVIMConversationCreateOptions {
    public init(conversation: IAVIMConversation, signature: AVIMSignature? = nil) {
        self.conversation = conversation
        self.signature = signature
    }
    var conversation: IAVIMConversation
    var signature: AVIMSignature?
}

public struct AVIMConnectOptions {
    var clientId: String
    var deviceToken: String?
    var tag: String?
    var st: String?
    var lastUnreadNotifTime: Double?
    var signature: AVIMSignature?
}

public class RxAVRealtime {
    public static let sharedInstance = RxAVRealtime(app: nil)
    public var onMessage: Observable<IAVIMMessage>?
    var app: RxAVApp
    var idSeed: Int = -65535;
    func cmdIdAutomation() -> Int {
        return self.idSeed + 1
    }
    public init(app: RxAVApp? = nil) {
        self.app = RxAVClient.sharedInstance.getCurrentApp()
    }

    public func connect(clientId: String, signature: AVIMSignature? = nil) throws -> Observable<[String:Any]> {
        return RxAVWebSocket.sharedInstance.open().flatMap { (success) -> Observable<[String:Any]> in
            let options = AVIMConnectOptions(clientId: clientId, deviceToken: nil, tag: nil, st: nil, lastUnreadNotifTime: nil, signature: signature)
            return try self.connectWithOptions(options: options)
        }
    }

    public func connectWithOptions(options: AVIMConnectOptions) throws -> Observable<[String:Any]> {
        var cmdBody = [
            "cmd": "session",
            "op": "open",
            "appId": self.app.appId,
            "peerId": options.clientId,
            "i": self.cmdIdAutomation(),
            "ua": "rx-lean-swift/\(RxAVClient.sharedInstance.getSDKVersion())",
        ] as [String: Any]

        if options.tag != nil {
            cmdBody["tag"] = options.tag
        }
        if options.deviceToken != nil {
            cmdBody["deviceToken"] = options.deviceToken
        }
        if options.signature != nil {
            cmdBody["t"] = options.signature?.timestamp
            cmdBody["n"] = options.signature?.noce
            cmdBody["s"] = options.signature?.signature
        }
        return try RxAVWebSocket.sharedInstance.send(json: cmdBody)
    }

    public func connectWithUser(user: RxAVUser) throws -> Observable<[String:Any]> {
        return try self.connect(clientId: user.username)
    }

    public func create(options: AVIMConversationCreateOptions) throws -> Observable<IAVIMConversation> {
        var options = options
        var cmdBody = [
            "cmd": "conv",
            "op": "start",
            "m": options.conversation.members,
            "attr": options.conversation.attributes,
            "appId": self.app.appId,
            "peerId": options.conversation.creator,
            "transient": options.conversation.transient,
            "unique": options.conversation.unique
        ] as [String: Any]
        if options.signature != nil {
            cmdBody["t"] = options.signature?.timestamp
            cmdBody["n"] = options.signature?.noce
            cmdBody["s"] = options.signature?.signature
        }

        return try RxAVWebSocket.sharedInstance.send(json: cmdBody).map({ (response) -> IAVIMConversation in
            options.conversation.conversationId = response["cid"] as! String
            return options.conversation
        })
    }

    public func send(options: AVIMMessageSendOptions) throws -> Observable<IAVIMMessage> {
        var options = options
        let cmdBody = [
            "cmd": "direct",
            "cid": options.conversationId,
            "r": options.receipt,
            "transient": options.transient,
            "msg": options.message.serialize(),
            "appId": self.app.appId,
            "peerId": options.clientId,
            "level": options.priority
        ] as [String: Any]

        return try RxAVWebSocket.sharedInstance.send(json: cmdBody).map({ (response) -> IAVIMMessage in
            options.message.id = response["uid"] as! String
            return options.message
        })
    }
}
