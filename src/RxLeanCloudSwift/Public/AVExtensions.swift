//
//  RxAVExtensions.swift
//  RxLeanCloudSwift
//
//  Created by WuJun on 27/05/2017.
//  Copyright © 2017 LeanCloud. All rights reserved.
//

import Foundation
import RxSwift

extension Dictionary {

    func containsKey(key: Key) -> Bool {
        return self.keys.contains(key)
    }

    func tryGetValue(key: Key) -> Value? {
        if self.containsKey(key: key) {
            return self[key]
        }
        return nil
    }

    func JSONStringify(prettyPrinted: Bool = false) -> String {
        let options = prettyPrinted ? JSONSerialization.WritingOptions.prettyPrinted : JSONSerialization.WritingOptions(rawValue: 0)
        if JSONSerialization.isValidJSONObject(self) {
            do {
                let data = try JSONSerialization.data(withJSONObject: self, options: options)
                if let string = NSString(data: data, encoding: String.Encoding.utf8.rawValue) {
                    return string as String
                }
            } catch {
                print(error.localizedDescription)
                //Access error here
            }
        }
        return ""
    }
}

extension String {
    func toDictionary() -> [String: Any]? {
        if let data = self.data(using: .utf8) {
            do {
                return try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            } catch {
                print(error.localizedDescription)
            }
        }
        return nil
    }
}

extension AVObject {
    public func fetch(keys: [String]? = nil) -> Observable<AVObject> {
        var queryString = [String: Any]()
        if keys != nil {
            let encode = keys!.joined(separator: ",")
            queryString["include"] = encode
        }
        return AVObject.objectController.fetch(state: self._state, queryString: queryString).map({ (severState) -> AVObject in
            self.handleFetchResult(serverState: severState)
            return self
        })
    }
    public func unset(key: String) {
        self[key] = nil
    }

    public func save(_ completion: @escaping (AVObject) -> Void) {
        let subscription = self.save().subscribe { event in
            completion(event.element!)
        }
        subscription.dispose()
    }
}
