//
//  FileManager.swift
//  TLDR
//
//  Created by Suraj Pathak on 27/1/16.
//  Copyright © 2016 Suraj Pathak. All rights reserved.
//

import Foundation

/// FileManager manages copying, deleting, checking for existence of files in app documents directory
struct FileManager {
    static let fileManager = NSFileManager.defaultManager()
    static func copyFromSourceUrl(fromUrl: NSURL?, to toUrl: NSURL?, replaceIfExist: Bool, onSuccess successBlock: (() -> Void)? = nil) {
        guard let destinationUrl = toUrl,
            let destinationPath = destinationUrl.path,
            let sourceUrl = fromUrl else { return }
        if fileManager.fileExistsAtPath(destinationPath) {
            if !replaceIfExist {
                print("Directory exists. Not copying.")
                return
            } else {
                do {
                    try fileManager.removeItemAtURL(destinationUrl)
                } catch {}
            }
        }
        do {
            try fileManager.copyItemAtURL(sourceUrl, toURL: destinationUrl)
            dispatch_async(dispatch_get_main_queue(), {
                if let block = successBlock {
                    block()
                }
            })
        } catch let error as NSError {
            print("Error: copying file from \(sourceUrl) to \(destinationUrl) encountered error.\n \(error)")
        }
    }
}

extension FileManager {
    static func copyBundleToDocument(replace replaceIfExist: Bool) {
        let destinationUrl = FileManager.urlToTldrFolder()
        let sourceUrl = FileManager.urlToBundleFolder()
        copyFromSourceUrl(sourceUrl, to: destinationUrl, replaceIfExist: replaceIfExist, onSuccess: {
            StoreManager.updateDB()
        })
    }

    static func urlToTldrFolder() -> NSURL? {
        guard let documentUrl = fileManager.URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first else {
            // Create Directory and Copy
            return nil
        }
        let tldrUrl = documentUrl.URLByAppendingPathComponent("tldr")
        return tldrUrl
    }

    static func urlToIndexJson() -> NSURL? {
        guard let tldrFolder = urlToTldrFolder() else {
            return nil
        }
        return tldrFolder.URLByAppendingPathComponent("/pages/index.json")
    }

    static func urlToTldrUpdateFolder() -> NSURL? {
        guard let documentUrl = fileManager.URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first else {
            // Create Directory and Copy
            return nil
        }
        let tldrUrl = documentUrl.URLByAppendingPathComponent("tldr-update.zip")
        return tldrUrl
    }

    static func urlToBundleFolder() -> NSURL? {
        let path = NSBundle.mainBundle().URLForResource("tldr", withExtension: "bundle")
        return path
    }

    static func contentOfFileAtTldrPages(type: String, name: String) -> String? {
        guard let tldrFolderUrl = FileManager.urlToTldrFolder() else {
            return nil
        }
        let filePath = tldrFolderUrl.URLByAppendingPathComponent("/pages/\(type)/\(name).md")
        do {
            let value = try String(contentsOfURL: filePath, encoding: NSUTF8StringEncoding)
            return value
        } catch {
            return nil
        }
    }
}
