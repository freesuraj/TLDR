//
//  CommandHelper.swift
//  TLDR
//
//  Created by Suraj Pathak on 8/1/16.
//  Copyright © 2016 Suraj Pathak. All rights reserved.
//

import Foundation

/**
 *  All Types of Commands must conform to this Protocol
 */
protocol Command: Identifiable {
    var id: String { get }
    var name: String { get }
    var type: String { get }
    var output: NSAttributedString { get }
    var rawOutput: String { get }
}

struct TLDRCommand: Command {
    let nameTypeTuple : (String, String)
    var id: String {
        return "\(name)-\(type)"
    }
    var name: String {
        return nameTypeTuple.0
    }
    var type: String {
        return nameTypeTuple.1
    }
    
    var rawOutput: String {
        guard let content =
            FileManager.contentOfFileAtTldrPages(self.nameTypeTuple.1,
                name: self.nameTypeTuple.0) else {
                return Constant.pageNotFound
            }
        return content

    }
    
    var output: NSAttributedString {
        guard let content =
            FileManager.contentOfFileAtTldrPages(self.nameTypeTuple.1,
                name: self.nameTypeTuple.0) else {
                return MarkDownParser.attributedStringOfMarkdownString(Constant.pageNotFound)
            }
        return  MarkDownParser.attributedStringOfMarkdownString(content)

    }
    
    static func commonType(with name: String) -> TLDRCommand {
        return Self.init(name: name, type: "common")
    }

    init(name: String, type: String) {
        self.nameTypeTuple = (name, type)
    }
    
    var isFavorited: Bool {
        set {
            if newValue {
                StoreManager.addCommand(self, table: .favs)
            } else {
                StoreManager.removeCommand(self, table: .favs)
            }
        }
        get {
            return StoreManager.doesExist(self, table: .favs)
        }
    }
    
    var isVisited: Bool {
        set {
            StoreManager.addCommand(self, table: .history)
        }
        get {
            return StoreManager.doesExist(self, table: .favs)
        }
    }
    
}

enum SystemCommand: Command {
    case info
    case update
    case help
    case version
    case random
    
    var id: String {
        return name
    }

    var name: String {
        switch self {
        case .help:
            return "-h"
        case .update:
            return "-u"
        case .info:
            return "-i"
        case .random:
            return "-r"
        case .version:
            return "-v"
        }
    }
    var type: String {
        switch self {
        case .help:
            return "print help"
        case .update:
            return "update library"
        case .info:
            return "show info"
        case .random:
            return "show a random command"
        case .version:
            return "show current version"
        }
    }
    var output: NSAttributedString {
        switch self {
        case .help:
            return MarkDownParser.attributedStringOfMarkdownString(Constant.helpPage)
        case .info:
            return MarkDownParser.attributedStringOfMarkdownString(Constant.aboutUsMarkdown)
        case .version:
            return MarkDownParser.attributedStringOfMarkdownString(Constant.version)
        case .random:
            if let command = StoreManager.getRandomCommand() {
                return command.output
            }
        case .update:
            NetworkManager.checkAutoUpdate(printVerbose: true)
        }
        return NSAttributedString()
    }
    
    var rawOutput: String {
        switch self {
        case .help:
            return Constant.helpPage
        case .info:
            return Constant.aboutUsMarkdown
        case .version:
            return Constant.version
        case .random:
            if let command = StoreManager.getRandomCommand() {
                return command.rawOutput
            }
        case .update:
            NetworkManager.checkAutoUpdate(printVerbose: true)
        }
        
        return ""
    }
    
    static var startupInstruction: NSAttributedString {
        MarkDownParser.attributedStringOfMarkdownString(Constant.startUpInstruction)
    }
}
