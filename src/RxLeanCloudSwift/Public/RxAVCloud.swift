//
//  RxAVCloud.swift
//  RxLeanCloudSwift
//
//  Created by WuJun on 28/10/2017.
//  Copyright © 2017 LeanCloud. All rights reserved.
//

import Foundation
import RxSwift

/*
 * LeanEngine
 */
public class RxAVCloud {
    public static func callCloudFuntion(funtionName: String, payload: [String: Any]?, app: RxAVApp?) -> Observable<[String:Any]?> {
        var _app = app
        if _app == nil {
            _app = RxAVClient.sharedInstance.getCurrentApp()
        }
        let cmd = AVCommand(relativeUrl: "/functions/\(funtionName)", method: "POST", data: payload, app: _app!)
        return RxAVCorePlugins.sharedInstance.commandRunner.runRxCommand(command: cmd).map({ (avResponse) -> [String: Any]? in
            return avResponse.jsonBody
        })
    }
}

