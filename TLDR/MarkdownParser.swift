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
        let regexTypes = [RegexType.titleRegex, RegexType.subTitleRegex, RegexType.quoteRegex, RegexType.listRegex, RegexType.blockRegex, RegexType.italicRegex, RegexType.BoldRegex]
        
        let output = NSMutableAttributedString(string: markdown, attributes: RegexType.normalRegex.attributes())
        
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
    
    enum RegexType {
        case titleRegex, subTitleRegex, quoteRegex, listRegex, blockRegex, italicRegex, BoldRegex, normalRegex
        
        func regex() -> Regex {
            
            switch self {
            case .titleRegex:
                return Regex(pattern: "(\\s*#+)(.+)")
            case .subTitleRegex:
                return Regex(pattern: "([^\n\\s]*>)(.+)")
            case .quoteRegex:
                return Regex(pattern: "(`)(.+)(`)")
            case .listRegex:
                return Regex(pattern: "(\\s*-)(\\s+.+)")
            case .blockRegex:
                return Regex(pattern: "(\\{\\{)([^{}]+)(\\}\\})")
            case .italicRegex:
                return Regex(pattern: "(_)(.+)(_)")
            case .BoldRegex:
                return Regex(pattern: "(\\*)(.+)(\\*)")
            case .normalRegex:
                return Regex(pattern: ".+")
            }
        }
        
        func attributes() -> [String: AnyObject] {
            switch self {
            case .titleRegex:
                return [NSForegroundColorAttributeName:UIColor.whiteColor(), NSFontAttributeName: UIFont(name: "Courier", size: 30)!]
            case .subTitleRegex:
                return [NSForegroundColorAttributeName:UIColor.lightTextColor(), NSFontAttributeName: UIFont(name: "Courier", size: 18)!]
            case .quoteRegex:
                return [NSForegroundColorAttributeName:UIColor.greenColor(), NSFontAttributeName: UIFont(name: "Courier", size: 18)!]
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
        
        func templateIndexToRetain() -> (String, Int) {
            switch self {
            case .titleRegex:
                return ("$2", 2)
            case .subTitleRegex:
                return ("$2", 2)
            case .quoteRegex:
                return ("$2", 2)
            case .listRegex:
                return ("$0", 0)
            case .blockRegex:
                return ("$2", 2)
            case .italicRegex:
                return ("$2", 2)
            case .BoldRegex:
                return ("$2", 2)
            case .normalRegex:
                return ("$0", 0)
            }
        }
        
        func rangeIndicesToDelete() -> [Int]? {
            switch self {
            case .titleRegex:
                return [1]
            case .subTitleRegex:
                return [1]
            case .quoteRegex:
                return [1,3]
            case .listRegex:
                return nil
            case .blockRegex:
                return [1,3]
            case .italicRegex:
                return [1,3]
            case .BoldRegex:
                return [1,3]
            case .normalRegex:
                return nil
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
        let matches = self.internalExpression.matchesInString(input, options: [], range: NSMakeRange(0, input.characters.count))
        return matches
    }
}