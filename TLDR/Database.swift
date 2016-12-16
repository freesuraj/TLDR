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
    static let realm = StoreManager.safeRealm()
    static func safeRealm() -> Realm? {
        do {
            let r = try Realm()
            return r
        } catch {
            return nil
        }
    }

    static func addCommand(_ command: TLDRCommand) {
        guard let realm = realm else { return }
        if realm.isInWriteTransaction {
            writeToRealmDb(command)
        } else {
            do {
                try realm.write({
                    writeToRealmDb(command)
                })
            } catch {}
        }
    }

    static func writeToRealmDb(_ command: TLDRCommand) {
        guard let realm = realm else { return }
        realm.create(CommandRealm.self, value: ["name": command.nameTypeTuple.0, "type": command.nameTypeTuple.1], update: true)
    }
    
    static func commands(withKeyword keyword: String? = nil) -> [Command] {
        guard let realm = realm else { return []}
        if let key = keyword {
            return getMatchingCommands(key)
        }
        
        let results = realm.objects(CommandRealm.self)
        var output: [Command] = []
        for result in results {
            output.append(TLDRCommand(name: result.name, type: result.type))
        }
        return output
    }

    static func getMatchingTLDRCommands(_ keyword: String) -> [Command] {
        guard let realm = realm else { return []}
        let predicate = NSPredicate(format: "name CONTAINS[c] %@", keyword)
        let results = realm.objects(CommandRealm.self).filter(predicate)
        var output: [Command] = []
        for result in results {
            output.append(TLDRCommand(name: result.name, type: result.type))
        }
        return output
    }

    static func getRandomCommand() -> TLDRCommand? {
        guard let realm = realm else { return nil}
        let results = realm.objects(CommandRealm.self)
        let index = Int(arc4random_uniform(UInt32(results.count)))
        let randomCommand = results[index]
        return TLDRCommand(name: randomCommand.name, type: randomCommand.type)
    }

    static func updateDB() {
        guard let jsonUrl = FileManager.urlToIndexJson(),
            let jsonData = try? Data(contentsOf: jsonUrl as URL) else {
                return
        }
        do {
            let json = try JSONSerialization.jsonObject(with: jsonData, options: .allowFragments)
            if let jsonDict = json as? [String: Any], let commands = jsonDict["commands"] as? [[String: Any]] {
                for aCommand in commands {
                    guard let name = aCommand["name"]  as? String,
                        let platforms = aCommand["platform"] as? [String] else {
                            break
                    }
                    let command = TLDRCommand(name: name, type: platforms[0])
                    StoreManager.addCommand(command)
                }
            }
        } catch {}
    }

    static func getMatchingSystemCommands(_ input: String) -> [Command] {
        let commands: [Command] = [
            SystemCommand.info,
            SystemCommand.update,
            SystemCommand.help,
            SystemCommand.version,
            SystemCommand.random]

        return commands.sorted(by: { (c1, c2) -> Bool in
            if c2.name.hasPrefix(input) {
                return c1.name.hasPrefix(input) ? c2.name > c1.name : false
            } else {
                return c1.name.hasPrefix(input) ? true : c2.name > c1.name
            }
        })
    }

    static func getMatchingCommands(_ keyword: String) -> [Command] {
        if keyword.hasPrefix("-") {
            return getMatchingSystemCommands(keyword)
        }
        return getMatchingTLDRCommands(keyword)
    }
}
