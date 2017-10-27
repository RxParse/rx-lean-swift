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

    init(app: RxAVApp) {
        super.init(className: "_User", app: app)
    }
    convenience init() {
        self.init(app: RxAVClient.sharedInstance.getCurrentApp())
    }
    static var userController: IUserController {
        get {
            return RxAVCorePlugins.sharedInstance.userConroller
        }
    }

    static var kvStorageController: IRxKVStorage {
        get {
            return RxAVCorePlugins.sharedInstance.kvStorageController
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

    public var mobilePhoneVerified: Bool {
        get {
            let value = self.getProperty(key: "mobilePhoneVerified")
            return value == nil ? false : value as! Bool
        }
    }

    public static func logIn(username: String, password: String, app: RxAVApp? = nil) -> Observable<RxAVUser> {
        var _app = app
        if _app == nil {
            _app = RxAVClient.sharedInstance.getCurrentApp()
        }

        return self.userController.logIn(username: username, password: password, app: _app!).map({ (serverState) -> RxAVUser in
            let user = RxAVUser()
            user.handleLogInResult(serverState: serverState, app: _app!)
//            _ = user.saveToStorage().subscribe({ (success) in
//
//            })
            return user;
        })
    }

    func handleLogInResult(serverState: IObjectState, app: RxAVApp) -> Void {
        self._state.apply(state: serverState)
        self._state.app = app
        self._isDirty = false
    }

    func toJSON() -> [String: Any] {
        var data = [String: Any]()
        data["username"] = self.username
        data["sessionToken"] = self.sessionToken
        data["objectId"] = self.objectId
//        data["createdAt"] = self.createdAt
//        data["updatedAt"] = self.updatedAt
        return data;
    }

    public func saveToStorage() -> Observable<Bool> {
        let key = self._state.app?.getUserStorageKey()
        let value = self.toJSON()
        return RxAVUser.kvStorageController.saveJSON(key: key!, value: value).map { (jsonString) -> Bool in
            return jsonString.count > 0
        }
    }

    public static func current(app: RxAVApp? = nil) -> Observable<RxAVUser?> {
        var _app = app
        if _app == nil {
            _app = RxAVClient.sharedInstance.getCurrentApp()
        }
        return _app!.currentUser()
    }
}
