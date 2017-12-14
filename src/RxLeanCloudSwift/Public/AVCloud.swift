//
//  AVCloud.swift
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
public class AVCloud {
    public static func callCloudFuntion(funtionName: String, payload: [String: Any]?, app: AVApp?) -> Observable<[String:Any]?> {
        let cmd = AVCommand(relativeUrl: "/functions/\(funtionName)", method: "POST", data: payload, app: app)
        return AVClient.sharedInstance.runCommand(cmd: cmd).map({ (avResponse) -> [String: Any]? in
            return avResponse.jsonBody
        })
    }
}

