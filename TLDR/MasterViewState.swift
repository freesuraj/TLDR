//
//  MasterViewState.swift
//  TLDR
//
//  Created by Suraj Pathak on 10/3/2022.
//  Copyright © 2022 Suraj Pathak. All rights reserved.
//

import Foundation

enum MasterViewState {
    case search(String?)
    case favs(String?)
    case history(String?)
    case top(String?)
    
    var commands: [Command] {
        switch self {
        case .search(let keyword):
            return StoreManager.commands(withKeyword: keyword, table: .all)
        case .favs(let keyword):
            return StoreManager.commands(withKeyword: keyword, table: .favs)
        case .history(let keyword):
            return StoreManager.commands(withKeyword: keyword, table: .history)
        default:
            return StoreManager.commands(withKeyword: nil, table: .all)
        }
    }
    
    func updated(withText text: String?) -> MasterViewState {
        switch self {
        case .search: return .search(text)
        case .favs: return .favs(text)
        case .history: return .history(text)
        default:
            return self
        }
    }
    
}
