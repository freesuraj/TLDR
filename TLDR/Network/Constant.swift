//
//  Constants.swift
//  TLDR
//
//  Created by Suraj Pathak on 12/1/16.
//  Copyright © 2016 Suraj Pathak. All rights reserved.
//

import Foundation

struct Constant {
    
    // These urls could change over time, so please make sure to check for their validity from time to time
    static let tldrZipUrl = "https://github.com/tldr-pages/tldr/releases/latest/download/tldr-pages.zip"
    static let tldrIndexUrl = "https://github.com/tldr-pages/tldr/releases/latest/download/index.json"

    // swiftlint:disable line_length
    // swiftlint:disable trailing_whitespace
    // swiftlint:disable opening_brace
    static let aboutUsMarkdown = "*About this project*" +
        "\n" +
        "\n" +
        "\n" +
        "TLDR is a collection of simplified and community-driven man pages." +
        "\n" +
        "\n" +
        "TLDR stands for *Too Long; Didnot Read*. It originates in Internet slang, where it is used to indicate parts of the text skipped as too lengthy." +
        "Compared to man, it provides a concise and most-used description of a command." +
        "\n\n" +
        "*Help:*" +
        "\n" +
        " -h: shows help\n" +
        " -u: updates the library\n" +
        " -r: shows a random command\n" +
        " -i: shows info page\n" +
        " -v: shows current version\n" +
        "\n" +
        "\n" +
        "*Resources:*\n" +
        "tldr github page:\nhttps://github.com/tldr-pages/tldr" +
        "\n" +
        "my github page:\nhttps://github.com/freesuraj" +
        "\n" +
    "project open source page:\nhttps://github.com/freesuraj/TLDR"
    
    static let pageNotFound = "{{Command not found}}\n" +
        "\n" +
        "Try updating with *tldr -update*, or submit a pull request to:" +
        "\n" +
    "https://github.com/tldr-pages/tldr\n"
    
    static let helpPage = "\n\n*Help:*" +
        "\n" +
        " -h: shows help\n" +
        " -u: updates the library\n" +
        " -r: shows a random command\n" +
        " -i: shows info page\n" +
        " -v: shows current version\n"
    
    static let startUpInstruction = """
    Type in a command to look up. eg.
    
    {{curl}}
    {{zip}}
    {{ssh}}
    
    """
    
    static let version = "Version: \(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "0.1")"

}
