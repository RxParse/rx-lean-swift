//
//  RxAVClient.swift
//  RxLeanCloudSwift
//
//  Created by WuJun on 22/05/2017.
//  Copyright © 2017 LeanCloud. All rights reserved.
//

import Foundation
import RxSwift

public class RxAVClient {

    public static let sharedInstance = RxAVClient()

    public static func initialize(app: LeanCloudApp) -> RxAVClient {
        return RxAVClient.sharedInstance.add(app: app, replace: true)
    }

    var remoteApps = Array<LeanCloudApp>()
    var currentAppIndex = 0
    public func add(app: LeanCloudApp, replace: Bool = false) -> RxAVClient {
        self.remoteApps.append(app)
        if replace {
            currentAppIndex = self.remoteApps.count - 1
        }
        return self
    }

    enum AVClientError: Error {
        case uninitialized(error: String)
    }
    public func getCurrentApp() -> LeanCloudApp {
        return self.remoteApps[currentAppIndex]
    }

    public func getApp(shortName: String) -> LeanCloudApp {
        return self.remoteApps.first(where: { (app) -> Bool in
            return app.shortName == shortName
        })!
    }

    public func takeApp(app: LeanCloudApp?) -> LeanCloudApp {
        var _app = app
        if _app == nil {
            _app = RxAVClient.sharedInstance.getCurrentApp()
        }
        return _app!
    }

    var _enableLog: Bool = false
    public func toggleLog(enable: Bool = true) -> RxAVClient {
        _enableLog = enable
        return self;
    }

    var _eanbleWssForHttp = false;
    public func toggleWssAsHttp(enable: Bool = true) -> RxAVClient {
        _eanbleWssForHttp = enable
        return self;
    }

    public func httpRequest(url: String, method: String?, headers: [String: String]?, data: [String: Any]?) -> Observable<HttpResponse> {
        var method = method
        if method == nil {
            method = "GET"
        }
        let req = HttpRequest(method: method!, url: url, headers: headers, jsonData: data)
        return AVCorePlugins.sharedInstance.httpClient.rxExecute(httpRequest: req)
    }

    public func runCommand(cmd: AVCommand) -> Observable<AVCommandResponse> {
        return AVCorePlugins.sharedInstance.httpCommandRunner.runRxCommand(command: cmd)
    }

    func runCommandSuccessced(cmd: AVCommand) -> Observable<Bool> {
        return self.runCommand(cmd: cmd).map({ (avResponse) -> Bool in
            return avResponse.satusCode == 200
        })
    }

    public func websocketLog(cmd: AVCommand) -> Void {
        if _enableLog {
//            print("===Websocket-Command-START===")
            print("=>", cmd.data!)
//            print("===Websocket-Command-END===")
//            print("===Websocket-Response-START===")
//            print("<=", response.body!)
//            print("===Websocket-Response-END===")
//            print("===Websocket-Command-END===")
        }
    }

    public func httpLog(request: HttpRequest, response: HttpResponse) -> Void {
        if _enableLog {
            print("===HTTP-START===")
            print("===Request-START===")
            print("Url: ", request.url)
            print("Method: ", request.method)
            print("Headers: ", request.headers ?? ["no": "headers"])
            print("RequestBody(UTF8String): ", request.data?.stringfy(encoding: .utf8) ?? ["no": "body"])
            print("===Request-END===")
            print("===Response-START===")
            print("StatusCode: ", response.satusCode)
            print("ResponseBody: ", response.bodyString)
            print("===Response-END===")
            print("===HTTP-END===")
        }
    }

    public func getSDKVersion() -> String {
        return "0.1.0"
    }
}
