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
        let textView = app.otherElements.containingType(.Table, identifier:"Empty list").childrenMatchingType(.TextView).element

        let textField = app.textFields["_"]
        textField.tap()
        textField.typeText("git")
        app.typeText("\n")
        XCTAssertEqual(textField.title, "")
        snapshot("01_git")
        clearbuttonButton.tap()
        XCTAssertEqual(textView.title, "")
        
        textField.tap()
        textField.typeText("-r")
        snapshot("02_hint")
        app.typeText("\n")
        clearbuttonButton.tap()
        
        app.buttons["More Info"].tap()
        snapshot("03_info")
        clearbuttonButton.tap()
    }
    
    func testUIElements() {
        
        let app = XCUIApplication()
        let tfStaticText = app.staticTexts["tf"]
        tfStaticText.tap()
        tfStaticText.doubleTap()
        app.buttons["infoButton"].tap()
        
        let clearbuttonButton = app.buttons["clearButton"]
        clearbuttonButton.tap()
        app.staticTexts["$ tldr"].tap()
        
        let inputTextField = app.textFields["input"]
        inputTextField.tap()
        inputTextField.typeText("-")
        // Failed to find matching element please file bug (bugreport.apple.com) and provide output from Console.app
        inputTextField.tap()
        inputTextField.typeText("-hh")
        
        let deleteKey = app.keys["Delete"]
        deleteKey.tap()
        deleteKey.tap()
        inputTextField.tap()
        // Failed to find matching element please file bug (bugreport.apple.com) and provide output from Console.app
        // Failed to find matching element please file bug (bugreport.apple.com) and provide output from Console.app
        
        let tfStaticText2 = app.staticTexts["tf"]
        tfStaticText2.tap()
        tfStaticText2.doubleTap()
        inputTextField.tap()
        tfStaticText2.tap()
        tfStaticText2.pressForDuration(1.0);
        tfStaticText2.doubleTap()
        clearbuttonButton.tap()
        
    }}
