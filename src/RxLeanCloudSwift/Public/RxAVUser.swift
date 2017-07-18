//
//  RxAVUser.swift
//  RxLeanCloudSwift
//
//  Created by WuJun on 27/05/2017.
//  Copyright © 2017 LeanCloud. All rights reserved.
//

import Foundation
import RxSwift
import RxRealm
import RealmSwift

enum userError: Error {
    case canNotResetUsername
}

public class RxAVUser: RxAVObject {

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

//    public static func login(username: String, password: String) -> Observable<RxAVUser> {
//        
//    }
}
