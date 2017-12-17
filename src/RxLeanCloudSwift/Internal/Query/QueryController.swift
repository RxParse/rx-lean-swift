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

    var httpCommandRunner: IAVCommandRunner
    init(httpCommandRunner: IAVCommandRunner) {
        self.httpCommandRunner = httpCommandRunner
    }

    public func find(query: IAVQuery) -> Observable<Array<IObjectState>> {
        let relativeUrl = self.buildQueryString(query: query)
        let cmd = AVCommand(relativeUrl: relativeUrl, method: "GET", data: nil, app: query.app!)

        return self.httpCommandRunner.runRxCommand(command: cmd).map({ (avResponse) -> Array<IObjectState> in
            var body = (avResponse.jsonBody)!
            let results = body["results"] as! Array<Any>

            return results.map({ (item) -> IObjectState in
                let jsonResult = item as! [String: Any]
                let state = AVCorePlugins.sharedInstance.objectDecoder.decode(serverResult: jsonResult, decoder: AVCorePlugins.sharedInstance.avDecoder)
                return state
            })
        })
    }
    
    func buildQueryString(query: IAVQuery) -> String {
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

    public func buildQueryString(parameters: [String: Any]) -> String {
        var encodedArray = [String]()
        for (key, value) in parameters {
            let encodedValue = AVCorePlugins.sharedInstance.avEncoder.encode(value: value)
            let encodedJSONObject = encodedValue as! [String: Any]
            let encodedJSONString = encodedJSONObject.JSONStringify()
            let encodedKey = AVCorePlugins.sharedInstance.avEncoder.encode(value: key)
            encodedArray.append("\(encodedKey)=\(encodedJSONString)")
        }
        let queryString = encodedArray.joined(separator: "&")
        return queryString
    }

    func buildParameters(query: IAVQuery, includeClassName: Bool = false) -> [String: Any] {
        var result: [String: Any] = [String: Any]()
        if query.condition.count > 0 {
            let encodedWhere = AVCorePlugins.sharedInstance.avEncoder.encode(value: query.condition)
            let jsonObject = encodedWhere as! [String: Any]
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
