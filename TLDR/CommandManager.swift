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
protocol Command {
    var name: String { get }
    var type: String { get }
    var output: NSAttributedString { get }
}

struct TLDRCommand: Command {
    let nameTypeTuple : (String, String)
    var name: String {
        return nameTypeTuple.0
    }
    var type: String {
        return nameTypeTuple.1
    }
    var output: NSAttributedString {
        guard let content =
            FileManager.contentOfFileAtTldrPages(self.nameTypeTuple.1,
                name: self.nameTypeTuple.0) else { return MarkDownParser.attributedStringOfMarkdownString(Constant.pageNotFound) }
        return MarkDownParser.attributedStringOfMarkdownString(content)

    }

    init(name: String, type: String) {
        self.nameTypeTuple = (name, type)
    }
}

enum SystemCommand: Command {
    case Info
    case Update
    case Help
    case Version
    case Random

    var name: String {
        switch self {
        case Help:
            return "-h"
        case Update:
            return "-u"
        case Info:
            return "-i"
        case Random:
            return "-r"
        case Version:
            return "-v"
        }
    }
    var type: String {
        switch self {
        case Help:
            return "print help"
        case Update:
            return "update library"
        case Info:
            return "show info"
        case Random:
            return "show a random command"
        case Version:
            return "show current version"
        }
    }
    var output: NSAttributedString {
        switch self {
        case .Help:
            return MarkDownParser.attributedStringOfMarkdownString(Constant.helpPage)
        case .Info:
            return MarkDownParser.attributedStringOfMarkdownString(Constant.aboutUsMarkdown)
        case .Version:
            return MarkDownParser.attributedStringOfMarkdownString("Version: 1.0.0")
        case .Random:
            if let command = StoreManager.getRandomCommand() {
                return command.output
            }
        case .Update:
            NetworkManager.checkAutoUpdate(printVerbose: true)
        }
        return NSAttributedString()
    }
}
