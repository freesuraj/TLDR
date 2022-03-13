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
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testFileManager_bundlePath() {
        XCTAssertNotNil(FileManager.urlToBundleFolder())
    }
    
    func testFileManager_readAFile() {
        let fileurl = FileManager.urlToBundleFolder()!.appendingPathComponent("/pages/common/git.md")
        print("file url \(fileurl)")
        XCTAssertNotNil(fileurl)
    }
    
    func testFileManager_pathInDownloadFolder_doesnotexist() {
        let folder = FileManager.urlToTldrFolder()!.appendingPathComponent("InoExist")
        let fileExist = FileManager.fileManager.fileExists(atPath: folder.path)
        XCTAssertFalse(fileExist)
    }
    
    func testFileManager_pathInDownloadFolder_exist() {
        FileManager.copyBundleToDocument(replace: true)
        let folder = FileManager.urlToTldrFolder()!
        let fileExist = FileManager.fileManager.fileExists(atPath: folder.path)
        XCTAssertTrue(fileExist)
    }
    
    func testFileManager_readAFileFromDownloadFolder() {
        let content = FileManager.contentOfFileAtTldrPages("common", name: "git")
        XCTAssertNotNil(content)
        
    }
    
}
