//
//  CommandRealm.swift
//  TLDR
//
//  Created by Suraj Pathak on 10/1/16.
//  Copyright © 2016 Suraj Pathak. All rights reserved.
//

import Foundation
import RealmSwift

class CommandRealm: Object {
    dynamic var name = ""
    dynamic var type = ""
    
    override static func primaryKey() -> String? {
        return "name"
    }
}

struct StoreManager {
    static let realm = try! Realm()
    
    static func addCommand(command: Command) {
        if realm.inWriteTransaction {
            writeToRealmDb(command)
        }
        else {
            try! realm.write({
                writeToRealmDb(command)
            })
        }
    }
    
    static func writeToRealmDb(command: Command) {
        realm.create(CommandRealm.self, value: ["name": command.name, "type": command.type], update: true)
    }
    
    static func getMatchingCommands(keyword: String) -> [Command] {
        let predicate = NSPredicate(format: "name CONTAINS[c] %@", keyword)
        let results = realm.objects(CommandRealm).filter(predicate)
        var output: [Command] = []
        for result in results {
            output.append(Command(name: result.name, type: result.type))
        }
        return output
    }
    
    static func updateDB() {
        guard let jsonUrl = FileManager.urlToIndexJson(),
            let jsonData = NSData(contentsOfURL: jsonUrl) else {
                return
        }
        do {
            let json = try NSJSONSerialization.JSONObjectWithData(jsonData, options: .AllowFragments)
            if let commands = json["commands"] as? [AnyObject] {
                for aCommand in commands {
                    guard let name = aCommand["name"]  as? String,
                        let platforms = aCommand["platform"] as? [String] else {
                            break
                    }
                    let command = Command(name: name, type: platforms[0])
                    StoreManager.addCommand(command)
                }
            }
        } catch {}
    }
}

extension Results {
    func toArray<T>(ofType: T.Type) -> [T] {
        var array = [T]()
        for result in self {
            if let result = result as? T {
                array.append(result)
            }
        }
        return array
    }
}