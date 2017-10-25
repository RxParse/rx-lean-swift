//
//  RxKVStorage.swift
//  RxLeanCloudSwift
//
//  Created by WuJun on 05/06/2017.
//  Copyright © 2017 LeanCloud. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa


public class RxAVSettings {
    @objc dynamic var id = UUID().uuidString
    @objc dynamic var key: String = ""
    @objc dynamic var value: String = ""
}

public class RxKVStorage: IRxKVStorage {
    
    public func set(key: String, value: String) -> Observable<String> {

        UserDefaults.standard.set(value, forKey: key)
        return Observable.from([value])
    }

    public func get(key: String) -> Observable<String?> {
        return UserDefaults.standard.rx.observe(String.self, key)
    }

    public func remove(key: String) -> Observable<Bool> {
        UserDefaults.standard.removeObject(forKey: key)
        return Observable.from([true])
    }

}
