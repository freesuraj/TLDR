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

    static func addCommand(command: TLDRCommand) {
        guard let realm = realm else { return }
        if realm.inWriteTransaction {
            writeToRealmDb(command)
        } else {
            do {
                try realm.write({
                    writeToRealmDb(command)
                })
            } catch {}
        }
    }

    static func writeToRealmDb(command: TLDRCommand) {
        guard let realm = realm else { return }
        realm.create(CommandRealm.self, value: ["name": command.nameTypeTuple.0, "type": command.nameTypeTuple.1], update: true)
    }

    static func getMatchingTLDRCommands(keyword: String) -> [Command] {
        guard let realm = realm else { return []}
        let predicate = NSPredicate(format: "name CONTAINS[c] %@", keyword)
        let results = realm.objects(CommandRealm).filter(predicate)
        var output: [Command] = []
        for result in results {
            output.append(TLDRCommand(name: result.name, type: result.type))
        }
        return output
    }

    static func getRandomCommand() -> TLDRCommand? {
        guard let realm = realm else { return nil}
        let results = realm.objects(CommandRealm)
        let index = Int(arc4random_uniform(UInt32(results.count)))
        let randomCommand = results[index]
        return TLDRCommand(name: randomCommand.name, type: randomCommand.type)
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
                    let command = TLDRCommand(name: name, type: platforms[0])
                    StoreManager.addCommand(command)
                }
            }
        } catch {}
    }

    static func getMatchingSystemCommands(input: String) -> [Command] {
        let commands: [Command] = [
            SystemCommand.Info,
            SystemCommand.Update,
            SystemCommand.Help,
            SystemCommand.Version,
            SystemCommand.Random]

        return commands.sort({ (c1, c2) -> Bool in
            if c2.commandName.hasPrefix(input) {
                return c1.commandName.hasPrefix(input) ? c2.commandName > c1.commandName : false
            } else {
                return c1.commandName.hasPrefix(input) ? true : c2.commandName > c1.commandName
            }
        })
    }

    static func getMatchingCommands(keyword: String) -> [Command] {
        if keyword.hasPrefix("-") {
            return getMatchingSystemCommands(keyword)
        }
        return getMatchingTLDRCommands(keyword)
    }
}
