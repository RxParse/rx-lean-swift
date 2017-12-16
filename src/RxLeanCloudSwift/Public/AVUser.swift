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

public class AVUser: AVObject {

    init(app: AVApp) {
        super.init(className: "_User", app: app)
    }
    public convenience init() {
        self.init(app: AVClient.sharedInstance.getCurrentApp())
    }
    static var userController: IUserController {
        get {
            return AVCorePlugins.sharedInstance.userConroller
        }
    }

    static var kvStorageController: IKVStorage {
        get {
            return AVCorePlugins.sharedInstance.kvStorageController
        }
    }

    public var username: String {
        get {
            return self.get(key: "username") as! String
        }
        set {
            if self.sessionToken == nil {
                self.set(key: "username", value: newValue)
            }
        }
    }

    public var password: String? {
        get {
            return self.get(key: "password") as! String?
        }
        set {
            if self.sessionToken == nil {
                self.set(key: "password", value: newValue!)
            }
        }
    }

    public var sessionToken: String? {
        get {
            return self.get(key: "sessionToken") as? String
        }
    }

    public var mobilePhoneNumber: String? {
        get {
            return self.get(key: "mobilePhoneNumber") as? String
        }
        set {
            if self.sessionToken == nil {
                self.set(key: "mobilePhoneNumber", value: newValue!)
            }
        }
    }

    public var mobilePhoneVerified: Bool {
        get {
            let value = self.get(key: "mobilePhoneVerified")
            return value == nil ? false : value as! Bool
        }
    }

    public func signUp() -> Observable<Bool> {
        return self.create().flatMap ({ (state) -> Observable<Bool> in
            self.handleLogInResult(serverState: state, app: self._state.app!)
            return self.saveToStorage()
        })
    }

    func create() -> Observable<IObjectState> {
        return AVUser.userController.create(state: self._state, operations: self.currentOperations)
    }

    public static func logIn(username: String, password: String, app: AVApp? = nil) -> Observable<AVUser> {
        let _app = AVClient.sharedInstance.takeApp(app: app)
        let user = AVUser()
        return self.userController.logIn(username: username, password: password, app: _app).flatMap({ (serverState) -> Observable<Bool> in
            user.handleLogInResult(serverState: serverState, app: _app)
            return user.saveToStorage()
        }).map({ (saved) -> AVUser in
            return user
        })
    }

    func handleLogInResult(serverState: IObjectState, app: AVApp) -> Void {
        self._state.apply(state: serverState)
        self._state.app = app
        self._isDirty = false
    }

    func toJSON() -> [String: Any] {
        var data = [String: Any]()
        data["username"] = self.username
        data["sessionToken"] = self.sessionToken
        data["objectId"] = self.objectId
        return data;
    }

    public func saveToStorage() -> Observable<Bool> {
        let key = self._state.app?.getUserStorageKey()
        let value = self.toJSON()
        return AVUser.kvStorageController.saveJSON(key: key!, value: value).map { (jsonString) -> Bool in
            return jsonString.count > 0
        }
    }

    public static func current(app: AVApp? = nil) -> Observable<AVUser?> {
        var _app = app
        if _app == nil {
            _app = AVClient.sharedInstance.getCurrentApp()
        }
        return _app!.currentUser()
    }
}
