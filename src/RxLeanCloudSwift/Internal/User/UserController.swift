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
    var commandRunner: IAVCommandRunner
    init(commandRunner: IAVCommandRunner) {
        self.commandRunner = commandRunner
    }

    public func logIn(username: String, password: String, app: RxAVApp) -> Observable<IObjectState> {
        let data = ["username": username, "password": password]
        let cmd = AVCommand(relativeUrl: "/login", method: "POST", data: data, app: app)

        return self.commandRunner.runRxCommand(command: cmd).map({ (avResponse) -> IObjectState in
            return RxAVCorePlugins.sharedInstance.objectController.unpackResponse(avResponse: avResponse)
        })
    }
}

