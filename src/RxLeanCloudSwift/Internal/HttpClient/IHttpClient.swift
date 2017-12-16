//
//  IHttpClient.swift
//  RxLeanCloudSwift
//
//  Created by WuJun on 22/05/2017.
//  Copyright © 2017 LeanCloud. All rights reserved.
//

import Foundation
import RxSwift

public protocol IHttpClient {
    func rxExecute(httpRequest: HttpRequest) -> Observable<HttpResponse>
}
