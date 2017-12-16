//
//  AVCorePlugins.swift
//  RxLeanCloudSwift
//
//  Created by WuJun on 22/05/2017.
//  Copyright © 2017 LeanCloud. All rights reserved.
//

import Foundation

public class AVCorePlugins {
    static let sharedInstance = AVCorePlugins()

    private var _httpClient: IHttpClient = HttpClient.default as IHttpClient
    var httpClient: IHttpClient {
        get {
            return self._httpClient
        }
    }

    private var _httpCommandRunner: IAVCommandRunner? = nil
    var httpCommandRunner: IAVCommandRunner {
        get {
            if _httpCommandRunner == nil {
                _httpCommandRunner = AVHttpCommandRunner(httpClient: self.httpClient)
            }
            return self._httpCommandRunner!
        }
    }

    private var _webSocketCommandRunner: IAVCommandRunner? = nil
    var webSocketCommandRunner: IAVCommandRunner {
        get {
            if _webSocketCommandRunner == nil {
                _webSocketCommandRunner = AVWebSocketCommandRunner(websocketClient: self.webSocketClient)
            }
            return self._webSocketCommandRunner!
        }
    }

    private var _webSocketClient: IWebSokcetClient? = nil
    var webSocketClient: IWebSokcetClient {
        get {
            if _webSocketClient == nil {
                _webSocketClient = AVWebSocketClient()
            }
            return self._webSocketClient!
        }
    }

    private var _avEncoder: IAVEncoder = AVEncoder() as IAVEncoder
    var avEncoder: IAVEncoder {
        get {
            return self._avEncoder
        }
    }

    private var _avDecoder: IAVDecoder = AVDecoder() as IAVDecoder
    var avDecoder: IAVDecoder {
        get {
            return self._avDecoder
        }
    }

    private var _objectDecoder: IObjectDecoder = ObjectDecoder() as IObjectDecoder
    var objectDecoder: IObjectDecoder {
        get {
            return self._objectDecoder
        }
    }

    private var _objectController: IObjectController? = nil
    var objectController: IObjectController {
        get {
            if _objectController == nil {
                _objectController = ObjectController(httpCommandRunner: self.httpCommandRunner) as IObjectController
            }
            return _objectController!
        }
    }

    private var _queryController: IQueryController? = nil
    var queryController: IQueryController {
        get {
            if _queryController == nil {
                _queryController = QueryController(httpCommandRunner: self.httpCommandRunner) as IQueryController
            }
            return _queryController!
        }
    }

    private var _userController: IUserController? = nil
    var userConroller: IUserController {
        get {
            if _userController == nil {
                _userController = UserController(httpCommandRunner: self.httpCommandRunner) as IUserController
            }
            return _userController!
        }
    }

    private var _kvStorageController: IKVStorage? = nil
    var kvStorageController: IKVStorage {
        get {
            if _kvStorageController == nil {
                _kvStorageController = RxKVStorage() as IKVStorage
            }
            return _kvStorageController!
        }
    }

    static var dateFormatter: DateFormatter {
        get {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy'-'MM'-'dd'T'HH':'mm':'ss.SSS'Z'"
            formatter.timeZone = TimeZone(secondsFromGMT: 0)
            return formatter
        }
    }
}
