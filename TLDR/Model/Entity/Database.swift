//
//  CommandRealm.swift
//  TLDR
//
//  Created by Suraj Pathak on 10/1/16.
//  Copyright © 2016 Suraj Pathak. All rights reserved.
//

import Foundation
import RealmSwift

enum DBTable {
    case all, favs, history, top
    
    var tableType: CommandRealm.Type {
        switch self {
        case .favs: return Favs.self
        case .history: return History.self
        default: return CommandRealm.self
        }
    }
}

class CommandRealm: Object {
    @Persisted var name = ""
    @Persisted var type = ""
    override static func primaryKey() -> String? {
        return "name"
    }
    
}

class Favs: CommandRealm {}

class History: CommandRealm {}

