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
    static let fileManager = Foundation.FileManager.default
    static func copyFromSourceUrl(_ fromUrl: URL?, to toUrl: URL?, replaceIfExist: Bool, onSuccess successBlock: (() -> Void)? = nil) {
        guard let destinationUrl = toUrl,
            let sourceUrl = fromUrl else { return }
        if fileManager.fileExists(atPath: destinationUrl.path) {
            if !replaceIfExist {
                print("Directory exists. Not copying.")
                return
            } else {
                do {
                    try fileManager.removeItem(at: destinationUrl)
                } catch {}
            }
        }
        do {
            try fileManager.copyItem(at: sourceUrl, to: destinationUrl)
            DispatchQueue.main.async(execute: {
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

    static func urlToTldrFolder() -> URL? {
        guard let documentUrl = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
            // Create Directory and Copy
            return nil
        }
        let tldrUrl = documentUrl.appendingPathComponent("tldr")
        return tldrUrl
    }

    static func urlToIndexJson() -> URL? {
        guard let tldrFolder = urlToTldrFolder() else {
            return nil
        }
        return tldrFolder.appendingPathComponent("/pages/index.json")
    }

    static func urlToTldrUpdateFolder() -> URL? {
        guard let documentUrl = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
            // Create Directory and Copy
            return nil
        }
        let tldrUrl = documentUrl.appendingPathComponent("tldr-update.zip")
        return tldrUrl
    }

    static func urlToBundleFolder() -> URL? {
        let path = Bundle.main.url(forResource: "tldr", withExtension: "bundle")
        return path
    }

    static func contentOfFileAtTldrPages(_ type: String, name: String) -> String? {
        guard let tldrFolderUrl = FileManager.urlToTldrFolder() else {
            return nil
        }
        let filePath = tldrFolderUrl.appendingPathComponent("/pages/\(type)/\(name).md")
        do {
            let value = try String(contentsOf: filePath, encoding: String.Encoding.utf8)
            return value
        } catch {
            return nil
        }
    }
}
