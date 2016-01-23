//
//  Verbose.swift
//  TLDR
//
//  Created by Suraj Pathak on 21/1/16.
//  Copyright © 2016 Suraj Pathak. All rights reserved.
//

import Foundation

/// Handler to print live verbose (message) to console.
struct Verbose {
    typealias UpdateVerbose = (verbose: NSAttributedString) -> Void
    static var verboseUpdateBlock: UpdateVerbose?
    static var verboseOutput: String = ""

    static func out(text: String, verbose: Bool? = true) {
        if let v = verbose where v == false {
            print(text)
            return
        }
        self.verboseOutput = text + "\n"
        if let block = self.verboseUpdateBlock {
            block(verbose: MarkDownParser.attributedStringOfMarkdownString(self.verboseOutput))
        }
    }
}
