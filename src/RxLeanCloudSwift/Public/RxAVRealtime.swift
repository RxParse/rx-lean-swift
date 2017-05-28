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
    mutating func deserialize(data: [String: Any]) -> Void
    func serialize() -> String
    func validate(raw: String) -> Bool
}

public struct AVIMMessage: IAVIMMessage {

    public func validate(raw: String) -> Bool {
        return true
    }

    public func serialize() -> String {
        return self.raw
    }

    public mutating func deserialize(data: [String: Any]) {
        self.conversationId = data["cid"] as! String
        self.from = data["fromPeerId"] as! String
        self.raw = data["msg"] as! String
        self.id = data["id"] as! String
        self.timestamp = data["timestamp"] as! Double
    }

    public var from: String

    public var timestamp: Double

    public var id: String

    public var raw: String

    public var conversationId: String
}

public struct AVIMMessageSendOptions {
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
    public var clientId: String?
    var app: RxAVApp
    var idSeed: Int = -65535;
    private let lock = DispatchSemaphore(value: 1)
    func cmdIdAutomation() -> Int {
        lock.wait()
        defer { lock.signal() }
        idSeed += 1
        return idSeed
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
        self.clientId = options.clientId
        var cmdBody = self._makeCommand()
        cmdBody["ua"] = "rx-lean-swift/\(RxAVClient.sharedInstance.getSDKVersion())"
        cmdBody["cmd"] = "session"
        cmdBody["op"] = "open"

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
        var cmdBody = self._makeCommand()
        cmdBody["cmd"] = "conv"
        cmdBody["op"] = "start"
        cmdBody["m"] = options.conversation.members
        if options.conversation.attributes.count > 0 {
            cmdBody["attr"] = options.conversation.attributes
        }

        cmdBody["transient"] = options.conversation.transient
        cmdBody["unique"] = options.conversation.unique

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

    public func send(conversationId: String, jsonData: [String: Any], options: AVIMMessageSendOptions? = nil) throws -> Observable<IAVIMMessage> {
        var jsonData = jsonData
        let type = jsonData["type"] as! String
        switch type {
        case "text":
            jsonData = self._makeText(data: jsonData)
            break
        default: break
        }
        let optionx = options == nil ? AVIMMessageSendOptions(transient: false, receipt: true, priority: 3, pushData: ["alert": "您有一条消息"]) : options!
        let avMessage = AVIMMessage(from: self.clientId!, timestamp: 0, id: "", raw: jsonData.JSONStringify(), conversationId: "")
        return try self._send(conversationId: conversationId, message: avMessage, options: optionx)
    }

    func _send(conversationId: String, message: IAVIMMessage, options: AVIMMessageSendOptions) throws -> Observable<IAVIMMessage> {
        var message = message
        var cmdBody = self._makeCommand()
        cmdBody["cmd"] = "direct"
        cmdBody["cid"] = conversationId
        cmdBody["r"] = options.receipt
        cmdBody["transient"] = options.transient
        cmdBody["level"] = options.priority
        cmdBody["msg"] = message.serialize()

        return try RxAVWebSocket.sharedInstance.send(json: cmdBody).map({ (response) -> IAVIMMessage in
            message.id = response["uid"] as! String
            message.timestamp = response["t"] as! Double
            return message
        })
    }

    func _makeText(data: [String: Any]) -> [String: Any] {
        let text = data["text"] as! String
        let msg = [
            "_lctype": -1,
            "_lctext": text
        ] as [String: Any]

        return msg
    }

    func _makeCommand() -> [String: Any] {
        var cmd = [String: Any]()
        cmd["appId"] = self.app.appId
        if self.clientId != nil {
            cmd["peerId"] = self.clientId!
        }
        cmd["i"] = self.cmdIdAutomation()
        return cmd
    }
}
