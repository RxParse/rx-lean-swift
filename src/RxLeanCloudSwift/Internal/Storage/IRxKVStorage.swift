//
//  IRxKVStorage.swift
//  RxLeanCloudSwift
//
//  Created by WuJun on 05/06/2017.
//  Copyright © 2017 LeanCloud. All rights reserved.
//

import Foundation
import RxSwift

public protocol IRxKVStorage {

    /*
     return json-format String
     */
    func set(key: String, value: String) -> Observable<String>

    /*
     return removed cache string
     */
    func remove(key: String) -> Observable<Bool>

    /*
     return the json-format string by the given key
     */
    func get(key: String) -> Observable<String>
}
