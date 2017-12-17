//
//  IQueryController.swift
//  RxLeanCloudSwift
//
//  Created by WuJun on 26/05/2017.
//  Copyright © 2017 LeanCloud. All rights reserved.
//

import Foundation
import RxSwift

public protocol IQueryController {
    func find(query: IAVQuery) -> Observable<Array<IObjectState>>
    func buildQueryString(parameters: [String: Any]) -> String
}
