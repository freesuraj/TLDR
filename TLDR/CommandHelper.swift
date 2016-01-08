//
//  CommandHelper.swift
//  TLDR
//
//  Created by Suraj Pathak on 8/1/16.
//  Copyright © 2016 Suraj Pathak. All rights reserved.
//

import Foundation

struct CommandHelper {
    static func pathForType(type: String, command: String) {
        let path = NSBundle.mainBundle().pathForResource(command, ofType: ".md", inDirectory: "pages\(type)")
//        let value = path.val
    }
}

