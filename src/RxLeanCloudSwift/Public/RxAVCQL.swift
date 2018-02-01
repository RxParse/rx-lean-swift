//
//  RxAVCQL.swift
//  RxLeanCloudSwift
//
//  Created by WuJun on 14/12/2017.
//  Copyright © 2017 LeanCloud. All rights reserved.
//

import Foundation
import RxSwift

public class RxAVCQL<TEntity> where TEntity: IAVQueryable {
    public var cql: String
    public var placeholders: Array<Any>?

    public init(cql: String) {
        self.cql = cql
    }

    public func execute() -> Observable<Array<TEntity>> {
        var url = "/cloudQuery?cql=\(self.cql)"
        if let pValues = self.placeholders {
            let pStr = AVCorePlugins.sharedInstance.avEncoder.encode(value: pValues)
            url = "\(url)&pvalues=\(pStr)"
        }
        let cmd = AVCommand(relativeUrl: url, method: "GET", data: nil, app: nil)

        return RxAVClient.sharedInstance.runCommand(cmd: cmd).map({ (avResponse) -> Array<TEntity> in
            var body = (avResponse.jsonBody)!
            let results = body["results"] as! Array<Any>

            return results.map({ (item) -> TEntity in
                let jsonResult = item as! [String: Any]
                let state = AVCorePlugins.sharedInstance.objectDecoder.decode(serverResult: jsonResult, decoder: AVCorePlugins.sharedInstance.avDecoder)
                return TEntity(serverState: state)
            })
        })
    }
}
