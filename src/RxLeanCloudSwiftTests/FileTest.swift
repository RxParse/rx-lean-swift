//
//  FileTest.swift
//  RxLeanCloudSwiftTests
//
//  Created by WuJun on 19/12/2017.
//  Copyright © 2017 LeanCloud. All rights reserved.
//

import XCTest
import RxLeanCloudSwift

class FileTest: LeanCloudUnitTestBase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testSaveStringAsTextFile() {
        let textFile = RxAVFile.text(name: "test.txt", content: "I love LeanCloud", encoding: .utf8)
        let result = textFile.save().toBlocking().materialize()

        switch result {
        case .completed(let elements):
            print(elements[0].progress)
            //XCTFail("Expected result to complete with error, but result was successful.")
        case .failed(_, let error):
            print(error.localizedDescription)
        }
    }

    func testSaveStringAsTextFileWithMetaData() {
        let textFile = RxAVFile.text(name: "test.txt", content: "I love LeanCloud", encoding: .utf8)
        textFile.metaData!["author"] = "WuJun"
        let result = textFile.save().toBlocking().materialize()

        switch result {
        case .completed(let elements):
            print(elements[0].progress)
            //XCTFail("Expected result to complete with error, but result was successful.")
        case .failed(_, let error):
            print(error.localizedDescription)
        }
    }

    func testSaveExternalFile() {
        let Satomi_Ishihara = RxAVFile(name: "Satomi_Ishihara.gif", externalUrl: "http://ww3.sinaimg.cn/bmiddle/596b0666gw1ed70eavm5tg20bq06m7wi.gif")
        Satomi_Ishihara.metaData!["boyfriend"] = "WuJun"
        let result = Satomi_Ishihara.save().toBlocking().materialize()
        switch result {
        case .completed(let elements):
            print(elements[0].progress)
            //XCTFail("Expected result to complete with error, but result was successful.")
        case .failed(_, let error):
            print(error.localizedDescription)
        }
    }

    func testQueryFiles() {
        let query = RxAVFile.query()
        query.equalTo(key: "metaData.author", value: "WuJun")
        let result = query.find().toBlocking().materialize()

        switch result {
        case .completed(let elements):
            print(elements[0].count)
            //XCTFail("Expected result to complete with error, but result was successful.")
        case .failed(_, let error):
            print(error.localizedDescription)
        }
    }

}
