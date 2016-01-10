//
//  CommandHelper.swift
//  TLDR
//
//  Created by Suraj Pathak on 8/1/16.
//  Copyright © 2016 Suraj Pathak. All rights reserved.
//

import Foundation
import SSZipArchive
import CryptoSwift

struct Command {
    let name: String
    let type: String
}

struct CommandHelper {
    static func attributedTextForTLDRCommand(object: Command) -> NSAttributedString {
        guard let content = FileManager.contentOfFileAtTldrPages(object.type, name: object.name) else { return NSAttributedString() }
        return MarkDownParser.attributedStringOfMarkdownString(content)
    }
}

struct FileManager {
    static let fileManager = NSFileManager.defaultManager()
    static func copyFromSourceUrl(fromUrl: NSURL?, to toUrl: NSURL?, replaceIfExist: Bool) {
        guard let destinationUrl = toUrl,
            let destinationPath = destinationUrl.path,
            let sourceUrl = fromUrl else { return }
        if fileManager.fileExistsAtPath(destinationPath) {
            if !replaceIfExist {
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
                StoreManager.updateDB()
            })
        } catch let error as NSError {
            print("Error: copying file from \(sourceUrl) to \(destinationUrl) encountered error.\n \(error)")
        }
    }

    static func copyBundleToDocument(replaceIfExist: Bool) {
        let destinationUrl = FileManager.urlToTldrFolder()
        let sourceUrl = FileManager.urlToBundleFolder()
        copyFromSourceUrl(sourceUrl, to: destinationUrl, replaceIfExist: replaceIfExist)
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

struct NetworkManager {
    static func checkAutoUpdate() {
        let jsonSource = "https://raw.githubusercontent.com/tldr-pages/tldr/master/pages/index.json"
        guard let jsonPath = FileManager.urlToIndexJson() else {
            updateTldrLibrary()
            return
        }
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), {
                do {
                    let localJsonString = try String(contentsOfURL: jsonPath, encoding: NSUTF8StringEncoding)
                    guard let url = NSURL(string: jsonSource) else {
                        updateTldrLibrary()
                        return
                    }
                    do {
                        let serverJsonString = try String(contentsOfURL: url, encoding: NSUTF8StringEncoding)
                        if localJsonString.md5() == serverJsonString.md5() {
                            return
                        } else {
                            updateTldrLibrary()
                        }
                    } catch {}
                } catch {}
            })
    }

    static func updateTldrLibrary() {
        print("updating tldr library ..")
        let zipSource = "http://tldr-pages.github.io/assets/tldr.zip"
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), {
            guard let url = NSURL(string: zipSource),
                let data = NSData(contentsOfURL: url) else {
                    print("zip could not be downloaded")
                    return
            }
            if data.writeToFile(FileManager.urlToTldrUpdateFolder()!.path!, atomically: true) {
                let destinationUrl = FileManager.urlToTldrUpdateFolder()!.URLByDeletingPathExtension!
                if SSZipArchive.unzipFileAtPath(FileManager.urlToTldrUpdateFolder()!.path!, toDestination: destinationUrl.path!) {
                    print("file unzipped")
                    do {
                        try FileManager.fileManager.removeItemAtURL(FileManager.urlToTldrUpdateFolder()!)
                    } catch {}
                    FileManager.copyFromSourceUrl(destinationUrl, to: FileManager.urlToTldrFolder(), replaceIfExist: true)
                }
            }
        })
    }
}
