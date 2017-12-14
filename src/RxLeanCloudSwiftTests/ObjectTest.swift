//
//  ObjectTest.swift
//  RxLeanCloudSwift
//
//  Created by WuJun on 24/05/2017.
//  Copyright © 2017 LeanCloud. All rights reserved.
//

import XCTest
import RxLeanCloudSwift
import RxSwift
import Alamofire
import RxAlamofire
import RxTest
import RxBlocking


class ObjectTest: XCTestCase {

    override func setUp() {
        super.setUp()

        RxLeanCloudSwiftUtils.initialize()
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testCreareNewAVObject() {
        let todo = AVObject(className: "RxSwiftTodo")
        todo["foo"] = "bar"

        todo["num"] = 1
        todo.increase(key: "num", amount: 688)

        todo["json"] = ["key1": "value1", "key2": "value2"]

        todo["list"] = ["bar1", "bar2"]

        let result = todo.save()
            .toBlocking()
            .materialize()

        switch result {
        case .completed(let elements):
            print(elements[0].createdAt ?? "")
            //XCTFail("Expected result to complete with error, but result was successful.")
        case .failed(_, let error):
            print(error.localizedDescription)
        }
    }

    func testFetchObject() {
        let todo = AVObject.createWithoutData(classnName: "RxSwiftTodo", objectId: "59fc0fd52f301e0069c76a67")
        let result = todo.fetch()
            .toBlocking()
            .materialize()

        switch result {
        case .completed(let elements): do {
                if let num = elements[0]["num"] {
                    print("num:\(num)")
                }
            }
        case .failed(_, let error):
            print(error.localizedDescription)
        default:
            print("done")
        }
    }

    func testRemoveProperty() {
        let todo = AVObject(className: "RxSwiftTodo")
        todo["foo"] = "bar"
        let result = todo.save()
            .toBlocking()
            .materialize()

        todo["foo"] = nil

        let result2 = todo.save()
            .toBlocking()
            .materialize()
    }

    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        let scheduler = TestScheduler(initialClock: 0)

        let todo = AVObject(className: "SwiftTodo")
        todo["foo"] = "bar"
        let observable = todo.save()

        _ = todo.save().map { (avObject) -> String in
            return avObject.objectId!
        }.map { (str) -> Int in
            return str.characters.count
        }.subscribe({ print($0) })


        let results = scheduler.createObserver(AVObject.self)
        var subscription: Disposable! = nil
        scheduler.scheduleAt(50) { subscription = observable.subscribe(results) }
        scheduler.scheduleAt(600) { subscription.dispose() }
        scheduler.start()

        //print(results.events[0].value.element?.objectId)
        //XCTAssertTrue((results.events[0].value.element?.objectId?.characters.count)! > 0)
    }
    func testSaveInBackgroud() {
        let todo = AVObject(className: "SwiftTodo")
        todo["foo"] = "bar"
        todo.save { (avObject) in
            
        }
    }
    func testInit() {

        let scheduler = TestScheduler(initialClock: 0)
        let stringURL = "https://uay57kig.api.lncld.net/1.1/classes/SwiftTodo"
        let app: AVApp = AVApp(appId: "uay57kigwe0b6f5n0e1d4z4xhydsml3dor24bzwvzr57wdap", appKey: "kfgz7jjfsk55r5a8a3y4ttd3je1ko11bkibcikonk32oozww")
        let headers = app.getHeaders()
        var objData: [String: Any] = [String: Any]()
        objData["foo"] = "bar"
        let sessionManager = SessionManager()

        _ = URLSession.shared

        //        let observable = sessionManager.rx.responseJSON(Alamofire.HTTPMethod.post, stringURL, parameters: objData, encoding: URLEncoding.httpBody, headers: headers).map { (response, data) -> [String: Any] in
        //            let body = data as? [String: Any]
        //            print("body", body!)
        //            return body!
        //        }


        let observable = sessionManager.rx.json(HTTPMethod.get, stringURL, headers: headers)
            .observeOn(MainScheduler.instance)
            .asObservable()
        _ = scheduler.createObserver((Any).self)
        var subscription: Disposable! = nil

        scheduler.scheduleAt(50) { subscription = observable.subscribe(onNext: { (response) in
            print("response: \(response)")
        }, onError: { (error) in
                print("error: \(error)")
            }, onCompleted: {
                print("onCompleted")
            }, onDisposed: {

            })
        }
        scheduler.scheduleAt(500000) { subscription.dispose() }

        scheduler.start()

        //        let (result, obj) = Alamofire.request(Alamofire.HTTPMethod.post, stringURL, parameters: objData, encoding: URLEncoding.httpBody, headers: headers)
        //
        //        let json = obj as! [String: Any]
        //        print("json", json)

    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
