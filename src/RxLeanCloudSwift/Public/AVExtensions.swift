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

    func binarization() -> Data {
        if JSONSerialization.isValidJSONObject(self) {
            do {
                let data = try JSONSerialization.data(withJSONObject: self, options: [])
                return data
            } catch {
                print(error.localizedDescription)
                //Access error here
            }
        }
        return "".data(using: String.Encoding.utf8)!
    }
}

extension Data {
    func jsonfy() -> [String: Any]? {
        let utf8DecodedString = String(data: self, encoding: .utf8)
        let json = utf8DecodedString?.toDictionary()
        return json
    }

    func stringfy(encoding: String.Encoding) -> String {
        let decodedString = String(data: self, encoding: encoding)!
        return decodedString
    }
}
extension Date {
    var ticks: UInt64 {
        return UInt64(self.timeIntervalSince1970)
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

    public static func saveAll(objects: Array<AVObject>) -> Observable<Array<AVObject>> {
        let execute = objects.map { (ob) -> Observable<AVObject> in
            return ob.save()
        }
        return Observable.zip(execute)
    }
}

extension AVUser {
    public func associateAuthData(authType: String, authData: [String: Any]?) -> Observable<Bool> {
        if self.authData == nil {
            self.authData = [String: Any]()
        }

        if authData == nil {
            self.authData!.removeValue(forKey: authType)
        } else {
            self.authData![authType] = authData
        }

        return self.save().map({ (user) -> Bool in
            return user._isDirty == false
        })
    }

    public func disassociateWith(authType: String) -> Observable<Bool> {
        return self.associateAuthData(authType: authType, authData: nil)
    }
}
