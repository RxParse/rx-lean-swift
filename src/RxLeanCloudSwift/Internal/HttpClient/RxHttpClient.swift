//
//  RxHttpClient.swift
//  RxLeanCloudSwift
//
//  Created by WuJun on 23/05/2017.
//  Copyright © 2017 LeanCloud. All rights reserved.
//

import Foundation
import Alamofire
import RxSwift
import RxAlamofire

public class RxHttpClient: IRxHttpClient {

    public func execute(httpRequest: HttpRequest) -> Observable<HttpResponse> {
        let manager = self.getAlamofireManager()
        let method = self.getAlamofireMethod(httpRequest: httpRequest)

        return manager.rx.responseJSON(method, httpRequest.url, parameters: httpRequest.data, encoding: JSONEncoding.default, headers: httpRequest.headers).map { (response, data) -> HttpResponse in
            let body = data as? [String: Any]
            let httpResponse = HttpResponse(statusCode: response.statusCode, body: body)
            RxAVClient.sharedInstance.httpLog(request: httpRequest, response: httpResponse)
            return httpResponse
        }
    }

    func getAlamofireManager() -> Alamofire.SessionManager {
        let sessionManager = Alamofire.SessionManager.default
        return sessionManager
    }

    func getAlamofireMethod(httpRequest: HttpRequest) -> Alamofire.HTTPMethod {
        let methodLowerCase = httpRequest.method.uppercased()
        switch methodLowerCase {
        case "POST":
            return Alamofire.HTTPMethod.post
        case "PUT":
            return Alamofire.HTTPMethod.put
        case "DELETE":
            return Alamofire.HTTPMethod.delete
        default:
            return Alamofire.HTTPMethod.get
        }
    }
}
