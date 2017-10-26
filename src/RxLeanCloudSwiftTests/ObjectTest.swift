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
import RxTest
import Alamofire
import RxAlamofire

class ObjectTest: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        let app: RxAVApp = RxAVApp(appId: "uay57kigwe0b6f5n0e1d4z4xhydsml3dor24bzwvzr57wdap", appKey: "kfgz7jjfsk55r5a8a3y4ttd3je1ko11bkibcikonk32oozww")
        let sdk = RxAVClient.initialize(app: app)
        sdk.toggleLog(enable: true)
        
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        let scheduler = TestScheduler(initialClock: 0)
        
        let todo = RxAVObject(className: "SwiftTodo")
        todo["foo"] = "bar"
        let observable = todo.save()
        
        todo.save().map { (avObject) -> String in
            return avObject.objectId!
            }.map { (str) -> Int in
                return str.characters.count
            }.subscribe({ print($0) })
        
        
        
        let results = scheduler.createObserver(RxAVObject.self)
        var subscription: Disposable! = nil
        scheduler.scheduleAt(50) { subscription = observable.subscribe(results) }
        scheduler.scheduleAt(600) { subscription.dispose() }
        scheduler.start()
        
        //print(results.events[0].value.element?.objectId)
        //XCTAssertTrue((results.events[0].value.element?.objectId?.characters.count)! > 0)
    }
    
    func testInit() {
        
        let scheduler = TestScheduler(initialClock: 0)
        let stringURL = "https://uay57kig.api.lncld.net/1.1/classes/SwiftTodo"
        let app: RxAVApp = RxAVApp(appId: "uay57kigwe0b6f5n0e1d4z4xhydsml3dor24bzwvzr57wdap", appKey: "kfgz7jjfsk55r5a8a3y4ttd3je1ko11bkibcikonk32oozww")
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
