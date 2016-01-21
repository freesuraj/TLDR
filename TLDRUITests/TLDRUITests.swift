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
        let textField = app.textFields["_"]
        textField.typeText("git")
        snapshot("01_hint")
        app.typeText("\r")
        snapshot("02_command")
        textField.typeText("-r")
        app.typeText("\r")
        snapshot("03_random")
        textField.typeText("-i")
        app.typeText("\r")
        snapshot("03_info")
        app.buttons["clearButton"].tap()
        textField.typeText("man")
    }
}
