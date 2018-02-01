//
//  LeanEngine.swift
//  RxLeanCloudSwiftTests
//
//  Created by WuJun on 24/12/2017.
//  Copyright © 2017 LeanCloud. All rights reserved.
//

import XCTest
import RxLeanCloudSwift

class LeanEngine: LeanCloudUnitTestBase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testRPCCloudFunction() {
        let cloudFunction = GetMovieRPC(funtionName: "getStars", idProcessor: MovieIdProcessor())
        cloudFunction.execute(parameter: "1008").subscribe { (done) in
            let movie = done.element
            print("\(movie?.stars)")
        }
    }
}

class MovieIdProcessor: RxAVRPCFunctionConvertible {

    func encode(entity: String) -> [String: Any] {
        return ["id": entity];
    }

    func decode(resultDictionary: [String: Any]) -> Movie {
        let movie = Movie()
        movie.diretor = resultDictionary["diretor"] as! String
        movie.stars = resultDictionary["stars"] as! Int
        movie.name = resultDictionary["name"] as! String
        return movie
    }

    typealias ParameterType = String

    typealias ResultType = Movie
}

class Movie {
    
    public var stars: Int = 0
    public var name: String = ""
    public var diretor: String = ""
    public var id: String = ""
}

class GetMovieRPC: RxAVRPCFunction {
    var processor: MovieIdProcessor
    var functionName: String = ""
    init(funtionName: String, idProcessor: MovieIdProcessor) {
        self.functionName = funtionName
        self.processor = idProcessor
    }
}

