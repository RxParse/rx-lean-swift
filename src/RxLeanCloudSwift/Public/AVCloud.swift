//
//  AVCloud.swift
//  RxLeanCloudSwift
//
//  Created by WuJun on 28/10/2017.
//  Copyright © 2017 LeanCloud. All rights reserved.
//

import Foundation
import RxSwift

/*
 * LeanEngine
 */
public class AVCloud {
    public static func callCloudFuntion(functionName: String, payload: [String: Any]?, app: AVApp?) -> Observable<[String:Any]?> {
        let cmd = AVCommand(relativeUrl: "/functions/\(functionName)", method: "POST", data: payload, app: app)
        return AVClient.sharedInstance.runCommand(cmd: cmd).map({ (avResponse) -> [String: Any]? in
            return avResponse.jsonBody
        })
    }
}

public class AVCloudFunction {
    var functionName: String
    var parameters: [String: Any]?

    public init(functionName: String) {
        self.functionName = functionName
    }

    public func call() -> Observable<[String:Any]?> {
        let app = AVClient.sharedInstance.takeApp(app: nil)
        let cmd = AVCommand(relativeUrl: "/functions/\(self.functionName)", method: "POST", data: self.parameters, app: app)
        return AVClient.sharedInstance.runCommand(cmd: cmd).map({ (avResponse) -> [String: Any]? in
            return avResponse.jsonBody
        })
    }

    public func rpc() -> Observable<[String:Any]?> {
        let app = AVClient.sharedInstance.takeApp(app: nil)
        let cmd = AVCommand(relativeUrl: "/call/\(self.functionName)", method: "POST", data: self.parameters, app: app)
        return AVClient.sharedInstance.runCommand(cmd: cmd).map({ (avResponse) -> [String: Any]? in
            return avResponse.jsonBody
        })
    }
}

