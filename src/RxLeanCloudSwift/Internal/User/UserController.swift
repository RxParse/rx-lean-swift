//
//  UserController.swift
//  RxLeanCloudSwift
//
//  Created by WuJun on 27/05/2017.
//  Copyright © 2017 LeanCloud. All rights reserved.
//

import Foundation
import RxSwift

public class UserController: IUserController {
    var httpCommandRunner: IAVCommandRunner
    init(httpCommandRunner: IAVCommandRunner) {
        self.httpCommandRunner = httpCommandRunner
    }

    public func logIn(username: String, password: String, app: AVApp) -> Observable<IObjectState> {
        let data = ["username": username, "password": password]
        let cmd = AVCommand(relativeUrl: "/login", method: "POST", data: data, app: app)

        return self.httpCommandRunner.runRxCommand(command: cmd).map({ (avResponse) -> IObjectState in
            return AVCorePlugins.sharedInstance.objectController.unpackResponse(avResponse: avResponse)
        })
    }
    func create(state: IObjectState, operations: [String: IAVFieldOperation]) -> Observable<IObjectState> {
        let cmd = AVCorePlugins.sharedInstance.objectController.packRequest(state: state, operations: operations)
        return self.httpCommandRunner.runRxCommand(command: cmd).map({ (avResponse) -> IObjectState in
            return AVCorePlugins.sharedInstance.objectController.unpackResponse(avResponse: avResponse)
        })
    }
}

