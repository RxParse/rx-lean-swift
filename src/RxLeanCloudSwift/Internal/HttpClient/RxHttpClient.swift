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
        let urlEncoding = self.getAlamofireUrlEncoding(httpRequest: httpRequest)
        let escapedString = httpRequest.url.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)

        return manager.rx.responseData(method, escapedString!, parameters: httpRequest.data, encoding: urlEncoding, headers: httpRequest.headers).map { (response, data) -> HttpResponse in
//            let utf8DecodedString = String(data: data, encoding: .utf8)
//            var body = utf8DecodedString?.toDictionary()
//            if data is [String: Any] {
//                body = (data as? [String: Any])!
//            } else if data is Array<[String: Any]> {
//                let dataArray = data as! Array<[String: Any]>
//                body = ["results": dataArray]
//            }
            let httpResponse = HttpResponse(statusCode: response.statusCode, data: data)
            AVClient.sharedInstance.httpLog(request: httpRequest, response: httpResponse)
            return httpResponse
        }
    }

    func getAlamofireUrlEncoding(httpRequest: HttpRequest) -> ParameterEncoding {
        let methodLowerCase = httpRequest.method.uppercased()
        switch methodLowerCase {
        case "GET":
            return URLEncoding.default
        case "POST":
            return JSONEncoding.default
        case "PUT":
            return JSONEncoding.default
        default:
            return JSONEncoding.default
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
