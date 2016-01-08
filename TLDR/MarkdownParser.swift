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
        let output: NSMutableAttributedString = NSMutableAttributedString(string: markdown, attributes: RegexType.normalRegex.attributes())
        
        let regexes = [RegexType.titleRegex, RegexType.subTitleRegex, RegexType.quoteRegex, RegexType.listRegex, RegexType.blockRegex, RegexType.italicRegex, RegexType.BoldRegex]
        
        for regex in regexes {
            let matches = regex.regex().matchesInString(markdown)
            for aMatch in matches {
                output.addAttributes(regex.attributes(), range: aMatch.range)
            }
        }
        return output
    }
    
    enum RegexType {
        case titleRegex, subTitleRegex, quoteRegex, listRegex, blockRegex, italicRegex, BoldRegex, normalRegex
        
        func regex() -> Regex {
            
            switch self {
            case .titleRegex:
                return Regex(pattern: "/^###.+/")
            case .subTitleRegex:
                return Regex(pattern: "/^---.+/")
            case .quoteRegex:
                return Regex(pattern: "/`.*`/")
            case .listRegex:
                return Regex(pattern: "/^-.+/")
            case .blockRegex:
                return Regex(pattern: "{{.+}}")
            case .italicRegex:
                return Regex(pattern: "/^_.+_$/")
            case .BoldRegex:
                return Regex(pattern: "/^*.+*$/")
            case .normalRegex:
                return Regex(pattern: ".*")
            }
        }
        
        func attributes() -> [String: AnyObject] {
            switch self {
            case .titleRegex:
                return [NSForegroundColorAttributeName:UIColor.whiteColor(), NSFontAttributeName: UIFont(name: "Courier", size: 22)!]
            case .subTitleRegex:
                return [NSForegroundColorAttributeName:UIColor.lightTextColor(), NSFontAttributeName: UIFont(name: "Courier", size: 20)!]
            case .quoteRegex:
                return [NSForegroundColorAttributeName:UIColor.orangeColor(), NSFontAttributeName: UIFont(name: "Courier", size: 18)!]
            case .listRegex:
                return [NSForegroundColorAttributeName:UIColor.redColor(), NSFontAttributeName: UIFont(name: "Courier", size: 18)!]
            case .blockRegex:
                return [NSForegroundColorAttributeName:UIColor.lightTextColor(), NSFontAttributeName: UIFont(name: "Courier-Bold", size: 18)!]
            case .italicRegex:
                return [NSForegroundColorAttributeName:UIColor.whiteColor(), NSFontAttributeName: UIFont(name: "Courier-Oblique", size: 18)!]
            case .BoldRegex:
                return [NSForegroundColorAttributeName:UIColor.orangeColor(), NSFontAttributeName: UIFont(name: "Courier-Bold", size: 18)!]
            case .normalRegex:
                return [NSForegroundColorAttributeName:UIColor.whiteColor(), NSFontAttributeName: UIFont(name: "Courier", size: 18)!]
            }
        }
    }
}

struct Regex {
    let internalExpression: NSRegularExpression
    let pattern: String
    
    init(pattern: String) {
        self.pattern = pattern
        do {
            try internalExpression = NSRegularExpression(pattern: pattern, options: .CaseInsensitive)
        } catch {
            internalExpression = NSRegularExpression()
        }
    }
    
    func matchesInString(input: String) -> [NSTextCheckingResult] {
        let matches = self.internalExpression.matchesInString(input, options: NSMatchingOptions.WithTransparentBounds, range: NSMakeRange(0, input.characters.count))
        return matches
    }
}