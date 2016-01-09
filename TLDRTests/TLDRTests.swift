//
//  TLDRTests.swift
//  TLDRTests
//
//  Created by Suraj Pathak on 9/1/16.
//  Copyright © 2016 Suraj Pathak. All rights reserved.
//

import XCTest
@testable import TLDR

class TLDRTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testFileManager_bundlePath() {
        XCTAssertNotNil(FileManager.urlToBundleFolder())
    }
    
    func testFileManager_readAFile() {
        let url = FileManager.urlToBundleFolder()!
        let fileurl = url.URLByAppendingPathComponent("/pages/common/git.md")
        print("file url \(fileurl)")
        XCTAssertNotNil(fileurl)
    }
    
    func testFileManager_pathInDownloadFolder_doesnotexist() {
        let folder = FileManager.urlToTldrFolder()!.URLByAppendingPathComponent("InoExist")
        let fileExist = FileManager.fileManager.fileExistsAtPath(folder.path!)
        XCTAssertFalse(fileExist)
    }
    
    func testFileManager_pathInDownloadFolder_exist() {
        FileManager.copyBundleToDocument(true)
        let folder = FileManager.urlToTldrFolder()!
        let fileExist = FileManager.fileManager.fileExistsAtPath(folder.path!)
        XCTAssertTrue(fileExist)
    }
    
    func testFileManager_readAFileFromDownloadFolder() {
        let content = FileManager.contentOfFileAtTldrPages("common", name: "git")
        print("content \(content)")
        XCTAssertNotNil(content)
        
    }
    
}
