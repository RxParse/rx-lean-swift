//
//  RxWebSocketClient.swift
//  RxLeanCloudSwift
//
//  Created by WuJun on 27/05/2017.
//  Copyright © 2017 LeanCloud. All rights reserved.
//

import Foundation
import RxSwift
import Starscream

public class RxWebSocketClient: IRxWebSokcetClient, WebSocketDelegate, WebSocketPongDelegate {
    
    public func websocketDidConnect(socket: WebSocketClient) {
        //print("connected with ", socket.currentURL)
        self.socket!.write(ping: Data())
        self.stateSubject.onNext(1)
    }
    
    public func websocketDidDisconnect(socket: WebSocketClient, error: Error?) {
        self.stateSubject.onNext(3)
    }
    
    public func websocketDidReceiveMessage(socket: WebSocketClient, text: String) {
        print("<=", text)
        guard let data = text.data(using: .utf8),
            let jsonData = try? JSONSerialization.jsonObject(with: data),
            let jsonDict = jsonData as? [String: Any]
            else {
                return
        }
        self.messageSubject.onNext(jsonDict)
    }
    
    public func websocketDidReceiveData(socket: WebSocketClient, data: Data) {
        
    }
    
    public func websocketDidReceivePong(socket: WebSocketClient, data: Data?) {
        print("pong<=", data!)
        self.socket?.write(ping: Data())
    }
    

    var socket: WebSocket?
    var messageSubject: PublishSubject<Any> = PublishSubject<Any>()
    var stateSubject: PublishSubject<Int> = PublishSubject<Int>()

    public var onMessage: Observable<AVCommandResponse>
    public var onState: Observable<Int>
    //public internal(set) var state: Int = 0

    init() {
        self.onMessage = messageSubject.asObservable().map({ (message) -> AVCommandResponse in
            let result = message as! [String: Any]
            var errorCode: Int?
            if result.containsKey(key: "code") {
                errorCode = result["code"] as? Int
            }
            let response = AVCommandResponse(statusCode: errorCode != nil ? errorCode! : 200, jsonBody: result)
            return response
        })
        self.onState = stateSubject.asObservable()
    }

    public func open(url: String, subprotocol: [String]?) -> Observable<Bool> {

        if (self.socket != nil) && (self.socket?.isConnected)! && (self.socket?.currentURL.absoluteString)! == url {
            return Observable.from([true])
        }
        print("try to connect \(url) connecting...")
        self.socket = WebSocket(url: URL(string: url)!, protocols: subprotocol)
        socket?.delegate = self
        socket?.connect()
        return self.onState.map({ (state) -> Bool in
            return (self.socket?.isConnected)!
        })
    }

    public func close() -> Observable<Bool> {
        socket?.disconnect()
        self.stateSubject.onNext(2)
        return self.onState.map({ (state) -> Bool in
            return (!(self.socket?.isConnected)!)
        })
    }

    public enum websocketError: Error {
        case connectionClosed
    }

    public func send(command: AVCommand) throws -> Observable<AVCommandResponse> {
        guard (self.socket?.isConnected)! else {
            throw websocketError.connectionClosed
        }
        self.socket?.write(string: (command.data?.JSONStringify())!)
        RxAVClient.sharedInstance.websocketLog(cmd: command)
        return self.onMessage.filter({ (avResponse) -> Bool in
            var matched = false
            if (avResponse.jsonBody?.containsKey(key: "i"))! && (command.data?.containsKey(key: "i"))! {
                let sent = avResponse.jsonBody?["i"] as! Int
                let received = command.data!["i"] as! Int
                matched = sent == received
            }
            return matched
        })
    }

//    public func websocketDidConnect(socket: Starscream.WebSocket) {
//        print("connected with ", socket.currentURL)
//        self.socket!.write(ping: Data())
//        self.stateSubject.onNext(1)
//    }
//
//    public func websocketDidDisconnect(socket: Starscream.WebSocket, error: NSError?) {
//        print("disconnected from ", socket.currentURL)
//        self.stateSubject.onNext(3)
//    }
//
//    public func websocketDidReceiveMessage(socket: Starscream.WebSocket, text: String) {
//        print("<=", text)
//        guard let data = text.data(using: .utf8),
//            let jsonData = try? JSONSerialization.jsonObject(with: data),
//            let jsonDict = jsonData as? [String: Any]
//            else {
//                return
//        }
//        self.messageSubject.onNext(jsonDict)
//    }
//
//    public func websocketDidReceiveData(socket: Starscream.WebSocket, data: Data) {
//
//    }
//
//    public func websocketDidReceivePong(socket: WebSocket, data: Data?) {
//        print("pong<=", data!)
//        self.socket?.write(ping: Data())
//    }
}
