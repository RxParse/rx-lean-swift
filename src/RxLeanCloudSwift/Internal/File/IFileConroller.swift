//
//  IFileConroller.swift
//  RxLeanCloudSwift
//
//  Created by WuJun on 17/12/2017.
//  Copyright © 2017 LeanCloud. All rights reserved.
//

import Foundation
import RxSwift

public protocol IFileConroller {
    func upload(state: FileState, dataStream: Data) -> Observable<AVUploadProgress>
    func get(objetcId: String) -> Observable<FileState>
    func DeleteAsync(objetcId: String) -> Observable<Bool>
}

public struct AVUploadProgress {
    
}
