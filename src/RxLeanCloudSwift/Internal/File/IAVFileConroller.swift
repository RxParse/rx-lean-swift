//
//  IFileConroller.swift
//  RxLeanCloudSwift
//
//  Created by WuJun on 17/12/2017.
//  Copyright © 2017 LeanCloud. All rights reserved.
//

import Foundation
import RxSwift

public protocol IAVFileConroller {
    func upload(state: FileState) -> Observable<AVUploadProgress>
    func save(state: FileState) -> Observable<AVUploadProgress>
    func get(objetcId: String, app: AVApp) -> Observable<FileState>
    func delete(state: FileState) -> Observable<Bool>
}

public protocol IFileUploader {
    func upload(state: FileState) -> Observable<AVUploadProgress>
    func setFileTokens(fileToken: [String: Any]) -> Void
}

public struct AVUploadProgress {
    public var progress: Double
}
