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

    public required init(serverState: IObjectState) {
        super.init(serverState: serverState)
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
            return self.get(defaultValue: "", key: "username")
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

    public var email: String? {
        get {
            return self.get(defaultValue: nil, key: "email")
        }
        set {
            self.set(key: "email", value: newValue)
        }
    }

    public var authData: [String: Any]? {
        get {
            let data = self.get(key: "authData")
            return data == nil ? nil : data as? [String: Any]
        }
        set {
            self.set(key: "authData", value: newValue)
        }
    }

    public func signUp() -> Observable<Bool> {
        return self.create().flatMap ({ (state) -> Observable<AVUser> in
            return AVUser.setCurrent(serverState: state)
        }).map({ (user) -> Bool in
            return user.objectId != nil
        })
    }

    public func logIn() -> Observable<AVUser> {
        var logInData = [String: Any]()
        if let password = self.password {
            logInData["password"] = password
        } else {
            return Observable.error(AVUserError.passwordNeededWhenLogIn(error: "Cannot log in user with an empty password."))
        }
        if let email = self.email {
            logInData["username"] = email
        }
        if let mobilePhomeNumber = self.mobilePhoneNumber {
            logInData["username"] = mobilePhomeNumber
        }
        if !self.username.isEmpty {
            logInData["username"] = self.username
        }
        return AVUser.userController.logInWith(relativeUrl: "/login", logInData: logInData, app: self.app).flatMap({ (serverState) -> Observable<AVUser> in
            return AVUser.setCurrent(serverState: serverState)
        })
    }
    public enum resetPasswordMode {
        case mobilePhoneNumber
        case email
    }

    public func requestResetPassword(_ mode: resetPasswordMode) -> Observable<Bool> {
        var requestData = [String: Any]()
        var url = ""
        switch mode {
        case .mobilePhoneNumber:
            requestData["mobilePhoneNumber"] = self.mobilePhoneNumber
            url = "/requestPasswordResetBySmsCode"
        default:
            requestData["email"] = self.email
            url = "/requestPasswordReset"
        }

        let cmd = AVCommand(relativeUrl: url, method: "POST", data: requestData, app: self.app)
        return AVClient.sharedInstance.runCommandSuccessced(cmd: cmd)
    }

    public func resetPassword(newPassword: String, shortCode: String) -> Observable<Bool> {
        var data = [String: Any]()
        data["password"] = newPassword
        let cmd = AVCommand(relativeUrl: "/resetPasswordBySmsCode/\(shortCode)", method: "POST", data: data, app: self.app)
        return AVClient.sharedInstance.runCommandSuccessced(cmd: cmd)
    }

    public func updatePassword(newPassword: String, oldPassword: String) -> Observable<Bool> {
        var data = [String: Any]()
        data["new_password"] = newPassword
        data["old_password"] = oldPassword
        let cmd = AVCommand(relativeUrl: "/users/\(String(describing: self.objectId))/updatePassword", method: "PUT", data: data, app: self.app)
        return AVClient.sharedInstance.runCommandSuccessced(cmd: cmd)
    }

    enum AVUserError: Error {
        case userExist(error: String)
        case usernameEmpty(error: String)
        case passwordNotSpecified(error: String)
        case passwordNeededWhenLogIn(error: String)
    }
    func create() -> Observable<IObjectState> {
        if self.objectId != nil {
            return Observable.error(AVUserError.userExist(error: "Cannot sign up a user that already exists."))
        }
        if self.authData == nil {
            if self.username.lengthOfBytes(using: String.Encoding.utf8) == 0 {
                return Observable.error(AVUserError.usernameEmpty(error: "Cannot sign up user with an empty name."))
            }
            if self.password == nil {
                return Observable.error(AVUserError.passwordNotSpecified(error: "Cannot sign up user with an empty password."))
            }
        }
        return AVUser.userController.create(state: self._state, operations: self.currentOperations)
    }

    static func setCurrent(serverState: IObjectState) -> Observable<AVUser> {
        let user = AVUser(serverState: serverState)
        user.handleLogInResult(serverState: serverState, app: user._state.app!)
        return user.saveToStorage().map({ (saved) -> AVUser in
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

    public static func logIn(username: String, password: String, app: AVApp? = nil) -> Observable<AVUser> {
        let _app = AVClient.sharedInstance.takeApp(app: app)
        return self.userController.logIn(username: username, password: password, app: _app).flatMap({ (serverState) -> Observable<AVUser> in
            return AVUser.setCurrent(serverState: serverState)
        })
    }

    public static func logIn(sms: AVUserAuthSMS) -> Observable<AVUser> {
        var logInData = [String: Any]()
        logInData["mobilePhoneNumber"] = sms.mobilePhoneNumber
        logInData["smsCode"] = sms.shortCode
        return AVUser.userController.logInWith(relativeUrl: "/login", logInData: logInData, app: sms.app).flatMap({ (serverState) -> Observable<AVUser> in
            return AVUser.setCurrent(serverState: serverState)
        })
    }

    public static func signUpOrLogIn(sms: AVUserAuthSMS) -> Observable<AVUser> {
        var logInData = [String: Any]()
        logInData["mobilePhoneNumber"] = sms.mobilePhoneNumber
        logInData["smsCode"] = sms.shortCode
        return AVUser.userController.logInWith(relativeUrl: "/usersByMobilePhone", logInData: logInData, app: sms.app).flatMap({ (serverState) -> Observable<AVUser> in
            return AVUser.setCurrent(serverState: serverState)
        })
    }

    public static func become(sessionToken: String, app: AVApp? = nil) -> Observable<AVUser> {
        let _app = AVClient.sharedInstance.takeApp(app: app)
        return AVUser.userController.get(sessionToken: sessionToken, app: _app).flatMap({ (serverState) -> Observable<AVUser> in
            return AVUser.setCurrent(serverState: serverState)
        })
    }

    public static func current(app: AVApp? = nil) -> Observable<AVUser?> {
        let _app = AVClient.sharedInstance.takeApp(app: app)
        return _app.currentUser()
    }

    public static func query() -> AVQuery<AVUser> {
        return AVQuery<AVUser>(className: "_User")
    }

    public func saveToStorage() -> Observable<Bool> {
        let key = self._state.app?.getUserStorageKey()
        let value = self.toJSON()
        return AVUser.kvStorageController.saveJSON(key: key!, value: value).map { (jsonString) -> Bool in
            return jsonString.count > 0
        }
    }


}

