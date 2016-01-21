//
//  CommandHelper.swift
//  TLDR
//
//  Created by Suraj Pathak on 8/1/16.
//  Copyright © 2016 Suraj Pathak. All rights reserved.
//

import Foundation

struct Command {
    let name: String
    let type: String
    var isSystemCommand: Bool = false

    init(name: String, type: String) {
        self.name = name
        self.type = type
        isSystemCommand = false
    }

    init(name: String, type: String, isSystemCommand: Bool) {
        self.name = name
        self.type = type
        self.isSystemCommand = isSystemCommand
    }

    static func systemCommands(input: String) -> [Command] {
        let commands = [
            Command(name: "-h", type: "print help", isSystemCommand: true),
            Command(name: "-u", type: "update library", isSystemCommand: true),
            Command(name: "-i", type: "show info", isSystemCommand: true),
            Command(name: "-r", type: "show a random command", isSystemCommand: true),
            Command(name: "-v", type: "show current version", isSystemCommand: true)]
        return commands.sort({ (c1, c2) -> Bool in
            if c2.name.hasPrefix(input) {
                return c1.name.hasPrefix(input) ? c2.name > c1.name : false
            } else {
                return c1.name.hasPrefix(input) ? true : c2.name > c1.name
            }
        })
    }
}

struct CommandHelper {

    static func attributedTextForSystemCommand(object: Command) -> NSAttributedString {
        guard object.isSystemCommand else {
            return NSAttributedString()
        }
        if object.name == "-h" {
            return MarkDownParser.attributedStringOfMarkdownString(Constant.helpPage)
        } else if object.name == "-i" {
            return MarkDownParser.attributedStringOfMarkdownString(Constant.aboutUsMarkdown)
        } else if object.name == "-v" {
            return MarkDownParser.attributedStringOfMarkdownString("version: 1.0.0")
        } else if object.name == "-r" {
            if let command = StoreManager.getRandomCommand() {
                return attributedTextForTLDRCommand(command)
            }
        } else if object.name == "-u" {
            NetworkManager.checkAutoUpdate(printVerbose: true)
        }
        return NSAttributedString()
    }

    static func attributedTextForTLDRCommand(object: Command) -> NSAttributedString {
        guard let content =
            FileManager.contentOfFileAtTldrPages(object.type,
                name: object.name) else { return MarkDownParser.attributedStringOfMarkdownString(Constant.pageNotFound) }
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
