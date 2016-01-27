//
//  TLDRUITests.swift
//  TLDRUITests
//
//  Created by Suraj Pathak on 10/1/16.
//  Copyright © 2016 Suraj Pathak. All rights reserved.
//

import XCTest

class TLDRUITests: XCTestCase {

    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        let app = XCUIApplication()
        setupSnapshot(app)
        app.launch()
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testExample() {
        
        let app = XCUIApplication()
        let clearbuttonButton = app.buttons["clearButton"]
        
        let inputTextField = app.textFields["input"]
        inputTextField.tap()
        inputTextField.typeText("git")
        app.typeText("\r")
        XCTAssertEqual(inputTextField.title, "")
        snapshot("01_git")
        clearbuttonButton.tap()
        app.buttons["randomButton"].tap()
        snapshot("02_random")
        clearbuttonButton.tap()
        app.buttons["infoButton"].tap()
        snapshot("03_info")
        clearbuttonButton.tap()
    }
}
