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
    func save(state: IObjectState, operations: [String: IAVFieldOperation]) -> Observable<IObjectState>
    func batchSave(states: [IObjectState], operations: Array<[String: IAVFieldOperation]>, app: LeanCloudApp) -> Observable<[IObjectState]>
    func delete(state: IObjectState, sessionToken: String?) -> Observable<Bool>
    func packRequest(state: IObjectState, operations: [String: IAVFieldOperation]) -> AVCommand
    func unpackResponse(avResponse: AVCommandResponse, app: LeanCloudApp) -> IObjectState
    func fetch(state: IObjectState, queryString: [String: Any]) -> Observable<IObjectState>
}
