//
//  FileState.swift
//  RxLeanCloudSwift
//
//  Created by WuJun on 14/12/2017.
//  Copyright © 2017 LeanCloud. All rights reserved.
//

import Foundation

public class FileState {
    public var objectId: String?
    public var name: String?
    public var cloudName: String?
    public var mimeType: String?
    public var url: String?
    public var metaData: [String: Any]?
    public var app: AVApp?
    public var data: Data?
    public var createdAt: Date?
    public var updatedAt: Date?

    public var isExternal: Bool {
        get {
            return self.objectId == nil && self.url != nil
        }
    }

    public var size: Int? {
        get {
            return self.data?.count
        }
    }

    init() {

    }
    convenience init(objectState: IObjectState) {
        self.init()
        if let cloudName = objectState.serverData["key"] as? String {
            self.cloudName = cloudName
        }
        if let name = objectState.serverData["name"] as? String {
            self.name = name
        }
        if let mimeType = objectState.serverData["mime_type"] as? String {
            self.mimeType = mimeType
        }
        if let url = objectState.serverData["url"] as? String {
            self.url = url
        }
        if let metaData = objectState.serverData["metaData"] as? [String: Any] {
            self.metaData = metaData
        }
        self.objectId = objectState.objectId
        self.createdAt = objectState.createdAt
        self.updatedAt = objectState.updatedAt
    }

    public func encode() -> [String: Any] {
        var result = [String: Any]()
        if let url = self.url {
            result["url"] = url
        }
        if let name = self.name {
            result["name"] = name
        }
        if let mime_type = self.mimeType {
            result["mime_type"] = mime_type
        }
        if let metaData = self.metaData {
            result["metaData"] = AVCorePlugins.sharedInstance.avEncoder.encode(value: metaData)
        }
        return result
    }
}
