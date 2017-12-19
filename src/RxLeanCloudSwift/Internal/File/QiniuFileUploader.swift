//
//  QiniuStrategy.swift
//  RxLeanCloudSwift
//
//  Created by WuJun on 14/12/2017.
//  Copyright © 2017 LeanCloud. All rights reserved.
//

import Foundation
import RxSwift

//extension Data {
//    func subdata(in range: ClosedRange<Index>) -> Data {
//        return subdata(in: range.lowerBound ..< range.upperBound + 1)
//    }
//}
class QiniuFileToken {
    public var url: String
    public var token: String
    public var bucket: String
    public var objectId: String
    public var uploadUrl: String

    public var uploadHttpHeaders: [String: String]
    init(url: String, token: String, bucket: String, objectId: String, uploadUrl: String) {
        self.url = url
        self.token = token
        self.bucket = bucket
        self.objectId = objectId
        self.uploadUrl = uploadUrl
        self.uploadHttpHeaders = [
            "Authorization": "UpToken \(token)"
        ]
    }

    public func getUploadHttpHeaders() -> [String: String] {
        return self.uploadHttpHeaders
    }
}

class QiniuShardUploadState {
    public var totalData: Data
    public var totalSize: Int
    public var completedSize: Int
    public var chunkSize: Int

    public var blockSize: Int {
        get {
            return 1024 * 1034 * 4
        }
    }
    public var blockCount: Int {
        get {
            let blockMashk: Int = 1 << 22 - 1
            return (self.totalSize + blockMashk) >> 22
        }
    }
    public var remainingSize: Int {
        get {
            return self.totalSize - self.completedSize
        }
    }

    init(data: Data) {
        self.totalData = data
        self.totalSize = self.totalData.count
        self.completedSize = 0
        self.chunkSize = 1024 * 1024 / 4
        //self.setChunkSize()
    }

    func setChunkSize() {
        self.chunkSize = 1024 * 1024 / 2 // 512kb
    }

    public func getNextChunk() -> Data {
        let realChunkSize = self.completedSize + self.chunkSize > self.totalSize ? self.remainingSize : self.remainingSize
        let bytes = self.totalData.subdata(in: self.completedSize..<self.completedSize + realChunkSize)
        return bytes
    }

    public func getNextBlockRealSize() -> Int {
        return self.remainingSize > self.blockSize ? self.blockSize : self.remainingSize
    }

}

class QiniuFileUploader: IFileUploader {
    var uploadToken: QiniuFileToken?
    var uploadState: QiniuShardUploadState?
    var httpClient: IHttpClient
    init(httpClient: IHttpClient) {
        self.httpClient = httpClient
    }

    var uploadHost = "https://up.qbox.me";
    var directUploadDataCriticalSize = 1024 * 1024 * 4

    public func upload(state: FileState) -> Observable<AVUploadProgress> {

        self.uploadState = QiniuShardUploadState(data: state.data!)
        if let size = self.uploadState?.totalSize {
            if size < directUploadDataCriticalSize {
                return self.directUpload(state: state)
            }
        }
        return self.shardUpload(state: state)
    }
    enum UploadError: Error {
        case directUploadFailed(error: String)
    }
    func directUpload(state: FileState) -> Observable<AVUploadProgress> {
        return self.httpDirectUploadToQiniu(fileData: state.data!, fileName: state.name!, mimeType: state.mimeType!, key: state.cloudName!, token: (self.uploadToken?.token)!, uploadHost: (self.uploadToken?.uploadUrl)!).map({ (response) -> AVUploadProgress in
            if response.satusCode == 200 {
                return AVUploadProgress(progress: 1)
            } else {
                //return UploadError.directUploadFailed(error: "directly upload to \((self.uploadToken?.uploadUrl)!) failed")
                return AVUploadProgress(progress: 0)
            }
        })
    }

    func shardUpload(state: FileState) -> Observable<AVUploadProgress> {
        return Observable.just(AVUploadProgress(progress: 1))
    }

    func httpDirectUploadToQiniu(fileData: Data, fileName: String, mimeType: String, key: String, token: String, uploadHost: String) -> Observable<HttpResponse> {
        let boundary = "---\(Date().ticks)"
        let boundaryData = "\r\n--\(boundary)\r\n".data(using: .ascii)!

        let contentType = "multipart/form-data; boundary=\(boundary)"

        var requestBody = Data()

        requestBody.append(boundaryData)
        let formDataKey = "Content-Disposition: form-data; name=\"key\"\r\n\r\n\(key)".data(using: .utf8)!
        requestBody.append(formDataKey)

        requestBody.append(boundaryData)
        let formDataToken = "Content-Disposition: form-data; name=\"token\"\r\n\r\n\(token)".data(using: .utf8)!
        requestBody.append(formDataToken)

        requestBody.append(boundaryData)
        let formDataFile = "Content-Disposition: form-data; name=\"file\"; filename=\"\(fileName)\"\r\nContent-Type:\(mimeType)\r\n\r\n".data(using: .utf8)!
        requestBody.append(formDataFile)
        requestBody.append(fileData)
        let trailer = "\r\n--\(boundary)--\r\n".data(using: .ascii)!
        requestBody.append(trailer)

        let url = uploadHost
        let headers = [
            "Content-Type": contentType
        ]

        let fileUploadRequest = HttpRequest(method: "POST", url: url, headers: headers, data: requestBody)
        return self.httpClient.rxExecute(httpRequest: fileUploadRequest)
    }

    func makeBlock() -> Observable<[String:Any]> {
        let firstChunkInBlock = self.uploadState!.getNextChunk()
        let blockRealSize = self.uploadState!.getNextBlockRealSize()
        var headers = self.uploadToken?.getUploadHttpHeaders()
        headers!["Content-Type"] = "application/octet-stream"
        let qiniuMakeBlockRequest = HttpRequest(method: "POST", url: "\(self.uploadHost)/mkblk/\(blockRealSize)", headers: headers, data: firstChunkInBlock)
        return self.httpClient.rxExecute(httpRequest: qiniuMakeBlockRequest).map({ (httpResponse) -> [String: Any] in
            return httpResponse.jsonBody!
        })
    }

//    func putChunk(chunkData: Data, lastChunkContext: String, currentChunkOffsetInBlock: Int) -> Observable<[String:Any]> {
//
//    }

    public func setFileTokens(fileToken: [String: Any]) -> Void {
        if let url = fileToken["url"] as? String,
            let bucket = fileToken["bucket"] as? String,
            let token = fileToken["token"] as? String,
            let objectId = fileToken["objectId"] as? String {
            var uploadUrl = self.uploadHost
            if let specifiedUploadHost = fileToken["upload_url"] as? String {
                uploadUrl = specifiedUploadHost
            }
            self.uploadToken = QiniuFileToken(url: url, token: token, bucket: bucket, objectId: objectId, uploadUrl: uploadUrl)
        }
    }

}

