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

    static func addCommand(command: Command) {
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

    static func writeToRealmDb(command: Command) {
        guard let realm = realm else { return }
        realm.create(CommandRealm.self, value: ["name": command.name, "type": command.type], update: true)
    }

    static func getMatchingCommands(keyword: String) -> [Command] {
        guard let realm = realm else { return []}
        let predicate = NSPredicate(format: "name CONTAINS[c] %@", keyword)
        let results = realm.objects(CommandRealm).filter(predicate)
        var output: [Command] = []
        for result in results {
            output.append(Command(name: result.name, type: result.type))
        }
        return output
    }

    static func getRandomCommand() -> Command? {
        guard let realm = realm else { return nil}
        let results = realm.objects(CommandRealm)
        let index = Int(arc4random_uniform(UInt32(results.count)))
        let randomCommand = results[index]
        return Command(name: randomCommand.name, type: randomCommand.type)
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
