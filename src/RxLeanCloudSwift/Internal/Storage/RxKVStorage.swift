//
//  RxKVStorage.swift
//  RxLeanCloudSwift
//
//  Created by WuJun on 05/06/2017.
//  Copyright © 2017 LeanCloud. All rights reserved.
//

import Foundation
import RxRealm
import RealmSwift
import RxSwift

public class RxAVSettings: RealmSwift.Object {
    dynamic var id = UUID().uuidString
    dynamic var key: String = ""
    dynamic var value: String = ""
}

public class RxKVStorage: IRxKVStorage {

    var realm = try! Realm()
    
    public func set(key: String, value: String) -> Observable<String> {
        let settings = RxAVSettings()
        settings.key = key;
        settings.value = value
        _ = Observable.from(object: settings).subscribe( realm.rx.add())

        return Observable.from([value])
    }

    public func get(key: String) -> Observable<String> {
        let settings = realm.objects(RxAVSettings.self).filter("key = \(key)")

        return Observable.collection(from: settings).map { (settings) -> String in
            if settings.count > 0 {
                let first = settings[0]
                return first.value
            }
            return ""
        }
    }

    public func remove(key: String) -> Observable<Bool> {
        let settings = realm.objects(RxAVSettings.self).filter("key = \(key)")

        _ = Observable.collection(from: settings).subscribe(realm.rx.delete())

        return Observable.from([true])
    }

}
