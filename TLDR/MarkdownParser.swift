//
//  MarkdownParser.swift
//  TLDR
//
//  Created by Suraj Pathak on 8/1/16.
//  Copyright © 2016 Suraj Pathak. All rights reserved.
//

import UIKit

struct MarkDownParser {
    static func attributedStringOfMarkdownString(markdown: String) -> NSAttributedString {
        let regexTypes: [RegexType] = [.Title, .SubTitle, .Quote, .List, .Block,.Italic, .BoldRegex]
        let output = NSMutableAttributedString(string: markdown, attributes: RegexType.Normal.attributes())
        var rangesToDelete: [NSRange] = []
        for regexType in regexTypes {
            let matches = regexType.regex().matchesInString(markdown)
            for aMatch in matches {
                output.setAttributes(regexType.attributes(), range: aMatch.range)
                if let indices = regexType.rangeIndicesToDelete() {
                    for index in indices {
                        rangesToDelete.append(aMatch.rangeAtIndex(index))
                    }
                }
            }
        }
        let filteredOutput = output.mutableCopy() as! NSMutableAttributedString
        let outputString = NSMutableString(string: output.string as NSString)
        output.beginEditing()
        for range in rangesToDelete {
            let characters = output.attributedSubstringFromRange(range)
            let newRange = outputString.rangeOfString(characters.string)
            filteredOutput.deleteCharactersInRange(newRange)
            outputString.deleteCharactersInRange(newRange)
        }
        output.endEditing()
        return filteredOutput
    }
    // MARK: Regex Types
    enum RegexType {
        case Title, SubTitle, Quote, List, Block, Italic, BoldRegex, Normal
        func regex() -> Regex {
            switch self {
            case .Title:
                return Regex(pattern: "(\\s*#+)(.+)")
            case .SubTitle:
                return Regex(pattern: "([^\n\\s]*>)(.+)")
            case .Quote:
                return Regex(pattern: "(`)(.+)(`)")
            case .List:
                return Regex(pattern: "(\\s*-)(\\s+.+)")
            case .Block:
                return Regex(pattern: "(\\{\\{)([^{}]+)(\\}\\})")
            case .Italic:
                return Regex(pattern: "(_)(.+)(_)")
            case .BoldRegex:
                return Regex(pattern: "(\\*)(.+)(\\*)")
            case .Normal:
                return Regex(pattern: ".+")
            }
        }
        // Return the attributes for the regex type
        func attributes() -> [String: AnyObject] {
            switch self {
            case .Title:
                return [NSForegroundColorAttributeName:UIColor.whiteColor(),
                    NSFontAttributeName: UIFont(name: "Courier", size: 22)!]
            case .SubTitle:
                return [NSForegroundColorAttributeName:UIColor.lightTextColor(),
                    NSFontAttributeName: UIFont(name: "Courier", size: 18)!]
            case .Quote:
                return [NSForegroundColorAttributeName:UIColor.greenColor(),
                    NSFontAttributeName: UIFont(name: "Courier", size: 18)!]
            case .List:
                return [NSForegroundColorAttributeName:UIColor.redColor(),
                    NSFontAttributeName: UIFont(name: "Courier", size: 18)!]
            case .Block:
                return [NSForegroundColorAttributeName:UIColor.lightTextColor(),
                    NSFontAttributeName: UIFont(name: "Courier-Bold", size: 18)!]
            case .Italic:
                return [NSForegroundColorAttributeName:UIColor.whiteColor(),
                    NSFontAttributeName: UIFont(name: "Courier-Oblique", size: 18)!]
            case .BoldRegex:
                return [NSForegroundColorAttributeName:UIColor.orangeColor(),
                    NSFontAttributeName: UIFont(name: "Courier-Bold", size: 18)!]
            case .Normal:
                return [NSForegroundColorAttributeName:UIColor.whiteColor(),
                    NSFontAttributeName: UIFont(name: "Courier", size: 18)!]
            }
        }
        // Returns a tuple of Template and index of the regex group that should remain
        func templateIndexToRetain() -> (String, Int) {
            switch self {
            case .Title:
                return ("$2", 2)
            case .SubTitle:
                return ("$2", 2)
            case .Quote:
                return ("$2", 2)
            case .List:
                return ("$0", 0)
            case .Block:
                return ("$2", 2)
            case .Italic:
                return ("$2", 2)
            case .BoldRegex:
                return ("$2", 2)
            case .Normal:
                return ("$0", 0)
            }
        }
        // Returns the ranges of indices of the regex group that should be deleted
        func rangeIndicesToDelete() -> [Int]? {
            switch self {
            case .Title:
                return [1]
            case .SubTitle:
                return [1]
            case .Quote:
                return [1,3]
            case .List:
                return nil
            case .Block:
                return [1,3]
            case .Italic:
                return [1,3]
            case .BoldRegex:
                return [1,3]
            case .Normal:
                return nil
            }
        }
    }
}

struct Regex {
    let internalExpression: NSRegularExpression
    let pattern: String
    // Initialization
    init(pattern: String) {
        self.pattern = pattern
        do {
            try internalExpression = NSRegularExpression(pattern: pattern, options: .CaseInsensitive)
        } catch {
            internalExpression = NSRegularExpression()
        }
    }
    func matchesInString(input: String) -> [NSTextCheckingResult] {
        // swiftlint:disable legacy_constructor
        let matches = self.internalExpression.matchesInString(input, options: [], range: NSMakeRange(0, input.characters.count))
        return matches
    }
}
