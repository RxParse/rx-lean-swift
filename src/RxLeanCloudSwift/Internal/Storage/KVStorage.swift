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


public class AVSettings {
    @objc dynamic var id = UUID().uuidString
    @objc dynamic var key: String = ""
    @objc dynamic var value: String = ""
}

public class RxKVStorage: IKVStorage {

    public func set(key: String, value: String) -> Observable<String> {
        UserDefaults.standard.set(value, forKey: key)
        return Observable.from([value])
    }

    public func get(key: String) -> Observable<String?> {
        let value = UserDefaults.standard.string(forKey: key)
        return Observable.from([value])
    }

    public func remove(key: String) -> Observable<Bool> {
        UserDefaults.standard.removeObject(forKey: key)
        return Observable.from([true])
    }

    public func saveJSON(key: String, value: [String: Any]) -> Observable<String> {
        let jsonString = value.JSONStringify()
        return self.set(key: key, value: jsonString)
    }
}
