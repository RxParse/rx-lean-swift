//
//  IUserController.swift
//  RxLeanCloudSwift
//
//  Created by WuJun on 27/05/2017.
//  Copyright © 2017 LeanCloud. All rights reserved.
//

import Foundation
import RxSwift

internal protocol IUserController {
    func logIn(username: String, password: String, app: LeanCloudApp) -> Observable<IObjectState>
    func logInWith(relativeUrl: String, logInData: [String: Any], app: LeanCloudApp) -> Observable<IObjectState>
    func create(state: IObjectState, operations: [String: IAVFieldOperation]) -> Observable<IObjectState>
    func get(sessionToken: String, app: LeanCloudApp) -> Observable<IObjectState>
}

