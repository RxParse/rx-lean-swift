//
//  RxAVUser.swift
//  RxLeanCloudSwift
//
//  Created by WuJun on 27/05/2017.
//  Copyright © 2017 LeanCloud. All rights reserved.
//

import Foundation
import RxSwift

enum userError: Error {
    case canNotResetUsername
}

public class RxAVUser: RxAVObject {

    static var userController: IUserController {
        get {
            return RxAVCorePlugins.sharedInstance.userConroller
        }
    }

    public var username: String {
        get {
            return self.getProperty(key: "username") as! String
        }
        set {
            if self.sessionToken == nil {
                self.setProperty(key: "username", value: newValue)
            }
        }
    }

    public var sessionToken: String? {
        get {
            return self.getProperty(key: "sessionToken") as? String
        }
    }

    public var mobilePhoneNumber: String? {
        get {
            return self.getProperty(key: "mobilePhoneNumber") as? String
        }
    }

    public static func logIn(username: String, password: String, app: RxAVApp? = nil) -> Observable<RxAVUser> {
        var _app = app
        if _app == nil {
            _app = RxAVClient.sharedInstance.getCurrentApp()
        }

        return self.userController.logIn(username: username, password: password, app: _app!).map({ (serverState) -> RxAVUser in
            let user = RxAVUser(className: "_User")
            user.handleLogInResult(serverState: serverState)
            return user;
        })
    }

    func handleLogInResult(serverState: IObjectState) -> Void {
        self._state.apply(state: serverState)
        self._isDirty = false
    }
}
