//
//  AlamofireHttpClient.swift
//  RxLeanCloudSwift
//
//  Created by WuJun on 23/05/2017.
//  Copyright © 2017 LeanCloud. All rights reserved.
//

import Foundation
import Alamofire
import RxSwift
import RxAlamofire
import RxCocoa

public class AlamofireHttpClient: IHttpClient {

    open static let `default`: AlamofireHttpClient = {
        return AlamofireHttpClient()
    }()

    static let backgroundQueue = DispatchQueue(label: "LeanCloud.AlamofireHttpClient", attributes: .concurrent)

    public func rxExecute(httpRequest: HttpRequest) -> Observable<HttpResponse> {
        let manager = self.getAlamofireManager()
        let method = self.getAlamofireMethod(httpRequest: httpRequest)
        let urlEncoding = self.getAlamofireUrlEncoding(httpRequest: httpRequest)
        let escapedString = httpRequest.url.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)

        return manager.rx.responseData(method, escapedString!, parameters: nil, encoding: urlEncoding, headers: httpRequest.headers).map { (response, data) -> HttpResponse in
            let httpResponse = HttpResponse(statusCode: response.statusCode, data: data)
            RxAVClient.sharedInstance.httpLog(request: httpRequest, response: httpResponse)
            return httpResponse
        }
    }

    public func syncExecute(httpRequest: HttpRequest) -> HttpResponse {
        let avResponse = HttpResponse(statusCode: -1, data: nil)
        let semaphore = DispatchSemaphore(value: 0)
        let queue = DispatchQueue(label: "cn.leancloud.sdk", qos: .background, attributes: .concurrent, autoreleaseFrequency: .inherit, target: nil)
        let manager = self.getAlamofireManager()
        let method = self.getAlamofireMethod(httpRequest: httpRequest)
        let urlEncoding = self.getAlamofireUrlEncoding(httpRequest: httpRequest)
        let escapedString = httpRequest.url.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)
        let alamofireRequest = manager.request(escapedString!, method: method, parameters: nil, encoding: urlEncoding, headers: httpRequest.headers)
        alamofireRequest.responseData(queue: queue, completionHandler: { alamofireResponse in
            switch alamofireResponse.result {
            case .success(_):
                if let httpResponse = alamofireResponse.response {
                    avResponse.satusCode = httpResponse.statusCode
                } else {
                    avResponse.satusCode = 400
                }
                if let data = alamofireResponse.data {
                    avResponse.data = data
                }
            case .failure(_):
                avResponse.satusCode = -1
            }
            semaphore.signal()
        })
        _ = semaphore.wait(timeout: DispatchTime.distantFuture)
        return avResponse
    }

    func asynchronize<Result>(_ task: @escaping () -> Result, completion: @escaping (Result) -> Void) {
        AVUtility.asynchronize(task, AlamofireHttpClient.backgroundQueue, completion)
    }

    public func callbackExecute(httpRequest: HttpRequest, _ completion: @escaping (HttpResponse) -> Void) {
        self.asynchronize({ self.syncExecute(httpRequest: httpRequest) }) { result in
            completion(result)
        }
    }

    func getAlamofireUrlEncoding(httpRequest: HttpRequest) -> ParameterEncoding {
        let methodUpperCase = httpRequest.method.uppercased()
        switch methodUpperCase {
        case "GET":
            return URLEncoding.default
        case "DELETE":
            return URLEncoding.default
        case "POST":
            return HttpBodyEncoding.data(data: httpRequest.data!)
        case "PUT":
            return HttpBodyEncoding.data(data: httpRequest.data!)
        default:
            return JSONEncoding.default
        }
    }

    func getAlamofireManager() -> Alamofire.SessionManager {
        let sessionManager = Alamofire.SessionManager.default
        return sessionManager
    }

    func getAlamofireMethod(httpRequest: HttpRequest) -> Alamofire.HTTPMethod {
        let methodUpperCase = httpRequest.method.uppercased()
        switch methodUpperCase {
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

enum HttpBodyEncoding: ParameterEncoding {
    case data(data: Data)
    func encode(_ urlRequest: URLRequestConvertible, with parameters: Parameters?) throws -> URLRequest {
        switch self {
        case .data(let data):
            var request = try urlRequest.asURLRequest()
            request.httpBody = data
            return request
//        default:
//            return urlRequest
        }
    }
}
