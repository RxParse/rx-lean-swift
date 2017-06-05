//
//  QueryController.swift
//  RxLeanCloudSwift
//
//  Created by WuJun on 26/05/2017.
//  Copyright © 2017 LeanCloud. All rights reserved.
//

import Foundation
import RxSwift

public class QueryController: IQueryController {

    var commandRunner: IAVCommandRunner
    init(commandRunner: IAVCommandRunner) {
        self.commandRunner = commandRunner
    }

    public func find(query: IRxAVQuery) -> Observable<Array<IObjectState>> {
        let relativeUrl = self.buildQueryString(query: query as! RxAVQuery)
        let cmd = AVCommand(relativeUrl: relativeUrl, method: "GET", data: nil, app: query.app!)

        return self.commandRunner.runRxCommand(command: cmd).map({ (avResponse) -> Array<IObjectState> in
            var body = (avResponse.body as? [String: Any])!
            let results = body["results"] as! Array<Any>

            return results.map({ (item) -> IObjectState in
                let jsonResult = item as! [String: Any]
                let state = RxAVCorePlugins.sharedInstance.objectDecoder.decode(serverResult: jsonResult, decoder: RxAVCorePlugins.sharedInstance.avDecoder)
                return state
            })
        })
    }
    func buildQueryString(query: RxAVQuery) -> String {
        let queryJson = self.buildParameters(query: query, includeClassName: false)

        var queryArray = [String]()
        var queryString = ""

        for (key, value) in queryJson {
            let qs = "\(key)=\(value)"
            queryArray.append(qs)
        }
        queryString = queryArray.joined(separator: "&")
        return "/classes/\(query.className!)?\(queryString)"
    }

    func buildParameters(query: IRxAVQuery, includeClassName: Bool = false) -> [String: Any] {
        var result: [String: Any] = [String: Any]()
        if query.condition.count > 0 {
            let encodedWhere = RxAVCorePlugins.sharedInstance.avEncoder.encode(value: query.condition)
            let jsonObject = encodedWhere as! [String:Any]
            result["where"] = jsonObject.JSONStringify()
        }
        if query.order != nil {
            result["order"] = query.order?.joined(separator: ",")
        }
        if query.limit > 0 {
            result["limit"] = query.limit
        }
        if query.skip > 0 {
            result["skip"] = query.skip
        }
        if query.include != nil {
            result["include"] = query.include?.joined(separator: ",")
        }
        if query.select != nil {
            result["keys"] = query.select?.joined(separator: ",")
        }
        return result
    }
}
