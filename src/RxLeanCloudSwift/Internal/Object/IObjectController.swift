//
//  IObjectController.swift
//  RxLeanCloudSwift
//
//  Created by WuJun on 23/05/2017.
//  Copyright © 2017 LeanCloud. All rights reserved.
//

import Foundation
import RxSwift

public protocol IObjectController {
    func save(state: IObjectState, estimatedData: [String: Any]) -> Observable<IObjectState>
    func batchSave(states: [IObjectState], estimatedDatas: Array<[String: Any]>, app: RxAVApp) -> Observable<[IObjectState]>
    func unpackResponse(avResponse: AVCommandResponse) -> IObjectState
}
