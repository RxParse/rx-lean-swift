//
//  RxAVCorePlugins.swift
//  RxLeanCloudSwift
//
//  Created by WuJun on 22/05/2017.
//  Copyright © 2017 LeanCloud. All rights reserved.
//

import Foundation

public class RxAVCorePlugins {
    static let sharedInstance = RxAVCorePlugins()

    private var _httpClient: IRxHttpClient = RxHttpClient() as IRxHttpClient
    var httpClient: IRxHttpClient {
        get {
            return self._httpClient
        }
    }

    private var _commandRunner: IAVCommandRunner? = nil
    var commandRunner: IAVCommandRunner {
        get {
            if _commandRunner == nil {
                _commandRunner = AVCommandRunner(httpClient: self.httpClient)
            }
            return self._commandRunner!
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
                _objectController = ObjectController(commandRunner: self.commandRunner) as IObjectController
            }
            return _objectController!
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
