//
//  MarkdownParser.swift
//  TLDR
//
//  Created by Suraj Pathak on 8/1/16.
//  Copyright © 2016 Suraj Pathak. All rights reserved.
//

import UIKit

struct MarkDownParser {
    
    static func attributedStringOfMarkdownString(_ markdown: String) -> NSAttributedString {
        let regexTypes: [RegexType] = [.title, .subTitle, .quote, .list, .block,.italic, .bold, .link]
        let output = NSMutableAttributedString(string: markdown, attributes: RegexType.normal.attributes())
        var rangesToDelete: [NSRange] = []
        for regexType in regexTypes {
            let matches = regexType.regex().matchesInString(markdown)
            for aMatch in matches {
                output.setAttributes(regexType.attributes(), range: aMatch.range)
                if regexType == .link {
                    let linkValue = output.attributedSubstring(from: aMatch.range)
                    output.addAttribute(NSAttributedString.Key.link, value: URL(string: linkValue.string)!, range: aMatch.range)
                }
                if let indices = regexType.rangeIndicesToDelete() {
                    for index in indices {
                        rangesToDelete.append(aMatch.range(at: index))
                    }
                }
            }
        }
        let filteredOutput = output.mutableCopy() as! NSMutableAttributedString
        let outputString = NSMutableString(string: output.string as NSString)
        output.beginEditing()
        for range in rangesToDelete {
            let characters = output.attributedSubstring(from: range)
            let newRange = outputString.range(of: characters.string)
            filteredOutput.deleteCharacters(in: newRange)
            outputString.deleteCharacters(in: newRange)
        }
        output.endEditing()
        return filteredOutput
    }
    
    // MARK: Regex Types
    enum RegexType {
        case title, subTitle, quote, list, block, italic, bold, link, normal
        func regex() -> Regex {
            switch self {
            case .title:
                return Regex(pattern: "(\\s*#+)(.+)")
            case .subTitle:
                return Regex(pattern: "([^\n\\s]*>)(.+)")
            case .quote:
                return Regex(pattern: "(`)(.+)(`)")
            case .list:
                return Regex(pattern: "(\\s*-)(\\s+.+)")
            case .block:
                return Regex(pattern: "(\\{\\{)([^{}]+)(\\}\\})")
            case .italic:
                return Regex(pattern: "(_)([^_\n]+)(_)")
            case .bold:
                return Regex(pattern: "(\\*)(.+)(\\*)")
            case .link:
                return Regex(pattern: "https?:\\/\\/(www\\.)?[-a-zA-Z0-9@:%._\\+~#=]{2,256}\\.[a-z]{2,6}\\b([-a-zA-Z0-9@:%_\\+.~#?&//=]*)")
            case .normal:
                return Regex(pattern: ".+")
            }
        }
        
        // Return the attributes for the regex type
        func attributes() -> [NSAttributedString.Key: AnyObject] {
            switch self {
            case .title:
                return [NSAttributedString.Key.foregroundColor:UIColor.white,
                        NSAttributedString.Key.font: UIFont(name: "Courier", size: 22)!]
            case .subTitle:
                return [NSAttributedString.Key.foregroundColor:UIColor.lightText,
                        NSAttributedString.Key.font: UIFont(name: "Courier", size: 18)!]
            case .quote:
                return [NSAttributedString.Key.foregroundColor:UIColor.green,
                        NSAttributedString.Key.font: UIFont(name: "Courier", size: 18)!]
            case .list:
                return [NSAttributedString.Key.foregroundColor:UIColor.red,
                        NSAttributedString.Key.font: UIFont(name: "Courier", size: 18)!]
            case .block:
                return [NSAttributedString.Key.foregroundColor:UIColor.lightText,
                        NSAttributedString.Key.font: UIFont(name: "Courier-Bold", size: 18)!]
            case .italic:
                return [NSAttributedString.Key.foregroundColor:UIColor.white,
                        NSAttributedString.Key.font: UIFont(name: "Courier-Oblique", size: 18)!]
            case .bold:
                return [NSAttributedString.Key.foregroundColor:UIColor.orange,
                        NSAttributedString.Key.font: UIFont(name: "Courier-Bold", size: 18)!]
            case .link:
                return [NSAttributedString.Key.foregroundColor:UIColor.blue,
                        NSAttributedString.Key.font: UIFont(name: "Courier", size: 16)!]
            case .normal:
                return [NSAttributedString.Key.foregroundColor:UIColor.white,
                        NSAttributedString.Key.font: UIFont(name: "Courier", size: 18)!]
            }
        }
        
        // Returns a tuple of Template and index of the regex group that should remain
        func templateIndexToRetain() -> (String, Int) {
            switch self {
            case .title:
                return ("$2", 2)
            case .subTitle:
                return ("$2", 2)
            case .quote:
                return ("$2", 2)
            case .list:
                return ("$0", 0)
            case .block:
                return ("$2", 2)
            case .italic:
                return ("$2", 2)
            case .bold:
                return ("$2", 2)
            case .link:
                return ("$0", 0)
            case .normal:
                return ("$0", 0)
            }
        }
        
        // Returns the ranges of indices of the regex group that should be deleted
        func rangeIndicesToDelete() -> [Int]? {
            switch self {
            case .title:
                return [1]
            case .subTitle:
                return [1]
            case .quote:
                return [1,3]
            case .list:
                return nil
            case .block:
                return [1,3]
            case .italic:
                return [1,3]
            case .bold:
                return [1,3]
            case .link:
                return nil
            case .normal:
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
            try internalExpression = NSRegularExpression(pattern: pattern, options: .caseInsensitive)
        } catch {
            internalExpression = NSRegularExpression()
        }
    }
    
    func matchesInString(_ input: String) -> [NSTextCheckingResult] {
        // swiftlint:disable legacy_constructor
        let matches = self.internalExpression.matches(in: input, options: [], range: NSMakeRange(0, input.count))
        return matches
    }
    
}
