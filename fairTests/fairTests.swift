//
//  fairTests.swift
//  fairTests
//
//  Created by Cameron Ehrlich on 9/19/17.
//  Copyright © 2017 fair. All rights reserved.
//

import XCTest
import SwiftyJSON

@testable import fair

class fairTests: XCTestCase {
    
    var makesJSON: JSON?
    var modelsJSON: JSON?
    var submodelsJSON: JSON?
    var overviewJSON: JSON?
    var articlesJSON: JSON?
    
    override func setUp() {
        super.setUp()
        makesJSON       = jsonFromFile(filename: "Makes")
        modelsJSON      = jsonFromFile(filename: "Models")
        submodelsJSON   = jsonFromFile(filename: "Submodels")
        overviewJSON    = jsonFromFile(filename: "Overview")
        articlesJSON    = jsonFromFile(filename: "Articles")
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testMakes() {
        XCTAssertNotNil(makesJSON)
        let makes = Make.list(from: makesJSON!)
        XCTAssert(makes.count == 44)
        let make = makes.first!
        XCTAssertNotNil(make.name)
        XCTAssertNotNil(make.niceName)
    }
    
    func testModels() {
        XCTAssertNotNil(modelsJSON)
        let models = Model.list(from: modelsJSON!)
        XCTAssert(models.count == 22)
        let model = models.first!
        XCTAssertNotNil(model.name)
        XCTAssertNotNil(model.niceName)
    }
    
    func testSubmodels() {
        XCTAssertNotNil(modelsJSON)
        let models = Model.list(from: modelsJSON!)
        XCTAssertNotNil(models)
        let model = models.first
        XCTAssertNotNil(model)
        let submodels = model?.submodels
        if let submodel = submodels?.first {
            XCTAssertNotNil(submodel.name)
            XCTAssertNotNil(submodel.niceName)
            XCTAssertNotNil(submodel.body)
            XCTAssertNotNil(submodel.trim)
            XCTAssertNotNil(submodel.modelName)
            XCTAssertNotNil(submodel.year)
            XCTAssertNotNil(submodel.detailText)
        }
    }
    
    func testOverview() {
        XCTAssertNotNil(overviewJSON)
        let overview = Overview(json: overviewJSON!)
        XCTAssertNotNil(overview)
        XCTAssertNotNil(overview.body)
        XCTAssertNotNil(overview.driving)
        XCTAssertNotNil(overview.edmundsSays)
        XCTAssertNotNil(overview.interior)
        XCTAssertNotNil(overview.introduction)
        XCTAssertNotNil(overview.powertrain)
        XCTAssertNotNil(overview.safety)
        XCTAssertGreaterThan(overview.otherInfoArray.count, 0)
    }
    
    func testArticles() {
        XCTAssertNotNil(articlesJSON)
        let articles = Article.list(from: articlesJSON!)
        XCTAssertNotNil(articles)
        XCTAssert(articles.count == 10)
        let article = articles.first
        XCTAssertNotNil(article)
        XCTAssertNotNil(article!.title)
        XCTAssertNotNil(article!.body)
        XCTAssertNotNil(article!.description)
        XCTAssertNotNil(article!.link)
    }
}

// MARK : Helpers
extension fairTests {
    func jsonFromFile(filename: String) -> JSON? {
        let testBundle = Bundle(for: type(of: self))
        guard let fileUrl = testBundle.url(forResource: filename, withExtension: "json") else {
            print("Invalid file URL \(filename) in \(#function)")
            return nil
        }
        do {
            let data = try Data(contentsOf: fileUrl)
            return JSON(data)
        } catch {
            print("Error decoding data - \(#function)")
            return nil
        }
    }
}
