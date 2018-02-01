//
//  RxAVRole.swift
//  RxLeanCloudSwift
//
//  Created by WuJun on 25/12/2017.
//  Copyright © 2017 LeanCloud. All rights reserved.
//

import Foundation
import RxSwift

public class RxAVRole: RxAVObject {

    init(name: String) {
        super.init(className: "_Role")
    }

    public required init(serverState: IObjectState) {
        //fatalError("init(serverState:) has not been implemented")
        super.init(serverState: serverState)
    }

    public var name: String {
        get {
            return self.get(defaultValue: "", key: "name")
        }
        set {
            if self.objectId == nil {
                self.set(key: "name", value: newValue)
            }
        }
    }

    public func grant(users: RxAVUser...) {
        
    }

    public func deprive(users: RxAVUser...) {
        
    }

    func buildRoleRelation(op: String, users: Array<RxAVUser>, roles: Array<RxAVRole>) {
        
    }
    
}

