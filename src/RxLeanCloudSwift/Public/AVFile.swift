//
//  AVFile.swift
//  RxLeanCloudSwift
//
//  Created by WuJun on 14/12/2017.
//  Copyright © 2017 LeanCloud. All rights reserved.
//

import Foundation
import RxSwift

public class AVFile: IAVQueryable {
    open static let `defaultClassName`: String = {
        return "_File"
    }()
    public required convenience init(serverState: IObjectState) {
        self.init()
        _ = self.retore(serverState: serverState)
    }

    public func retore(serverState: IObjectState) -> AVFile {
        let file = AVFile()
        file.state = FileState(objectState: serverState)
        return file
    }

    public typealias AVQueryableType = AVFile

    var state: FileState
    var _fileController: IAVFileConroller? = nil
    var fileController: IAVFileConroller {
        get {
            if let controller = self._fileController {
                return controller
            }
            self._fileController = AVFileController(fileUploader: (self.state.app?.getFileUploader())!, httpCommandRunner: AVCorePlugins.sharedInstance.httpCommandRunner) as IAVFileConroller
            return self._fileController!
        }
    }

    public var metaData: [String: Any]? {
        get {
            return self.state.metaData
        }
        set {
            self.state.metaData = newValue
        }
    }

    public var name: String? {
        get {
            return self.state.name
        }
        set {
            self.state.name = newValue
        }
    }

    public init() {
        self.state = FileState()
        self.state.app = AVClient.sharedInstance.takeApp(app: nil)
    }

    public convenience init(name: String, data: Data?) {
        self.init()
        self.state.name = name
        self.state.metaData = [String: Any]()

        if let _data = data {
            self.state.data = _data
            self.state.metaData!["size"] = self.state.size!
        }
    }

    public convenience init(name: String, data: Data, metaData: [String: Any]) {
        self.init(name: name, data: data)
        self.state.metaData = metaData
    }

    public convenience init(name: String, externalUrl: String) {
        self.init(name: name, data: nil)
        self.state.url = externalUrl
    }

    public static func text(name: String, content: String, encoding: String.Encoding) -> AVFile {
        let data = content.data(using: encoding)!
        let file = AVFile(name: name, data: data)
        return file
    }

    public static func query() -> AVQuery<AVFile> {
         return AVQuery<AVFile>(className: AVFile.defaultClassName)
    }

    public func save() -> Observable<AVUploadProgress> {
        return self.fileController.save(state: self.state)
    }
}
