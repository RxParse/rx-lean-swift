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
    public var size: Float = 0
}
