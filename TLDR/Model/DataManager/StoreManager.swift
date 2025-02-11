//
//  StoreManager.swift
//  TLDR
//
//  Created by Suraj Pathak on 11/2/2025.
//  Copyright © 2025 Suraj Pathak. All rights reserved.
//

import RealmSwift
import Foundation

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
    
    static func doesExist(_ command: TLDRCommand, table: DBTable = .all) -> Bool {
        return getMatchingCommands(command.name, table: table).count > 0
    }

    static func addCommand(_ command: TLDRCommand, table: DBTable = .all) {
        guard let realm = realm else { return }
        if realm.isInWriteTransaction {
            writeToRealmDb(command, table: table)
        } else {
            do {
                try realm.write({
                    writeToRealmDb(command, table: table)
                })
            } catch {}
        }
    }
    
    static func removeCommand(_ command: TLDRCommand, table: DBTable = .all) {
        guard let realm = realm else { return }
        realm.beginWrite()
        let predicate = NSPredicate(format: "name CONTAINS[c] %@", command.name)
        let results = realm.objects(table.tableType).filter(predicate)
        realm.delete(results)
        try? realm.commitWrite()
    }


    static func writeToRealmDb(_ command: TLDRCommand, table: DBTable = .all) {
        guard let realm = realm else { return }
        realm.create(table.tableType, value: ["name": command.nameTypeTuple.0, "type": command.nameTypeTuple.1], update: .all)
    }
    
    static func commands(withKeyword keyword: String? = nil, table: DBTable = .all) -> [any Command] {
        guard let realm = realm else { return []}
        if let key = keyword, !key.isEmpty {
            return getMatchingCommands(key, table: table)
        }
        
        let results = realm.objects(table.tableType)
        var output: [any Command] = []
        for result in results {
            output.append(TLDRCommand(name: result.name, type: result.type))
        }
        return output
    }

    static func getMatchingTLDRCommands(_ keyword: String, table: DBTable = .all) -> [TLDRCommand] {
        guard let realm = realm else { return [] }
        let predicate = NSPredicate(format: "name BEGINSWITH[c] %@", keyword)
        let results = realm.objects(table.tableType).filter(predicate).prefix(6)
        var output: [TLDRCommand] = []
        for result in results {
            output.append(TLDRCommand(name: result.name, type: result.type))
        }
        return output
    }

    static func getRandomCommand() -> TLDRCommand? {
        guard let realm = realm else { return nil}
        let results = realm.objects(CommandRealm.self)
        let index = Int(arc4random_uniform(UInt32(results.count)))
        guard index < results.count else { return nil}
        let randomCommand = results[index]
        return TLDRCommand(name: randomCommand.name, type: randomCommand.type)
    }

    static func updateDB() {
        guard let jsonUrl = FileManager.indexFileUrl(),
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

    static func getMatchingSystemCommands(_ input: String) -> [any Command] {
        let commands: [any Command] = [
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

    static func getMatchingCommands(_ keyword: String, table: DBTable = .all) -> [any Command] {
        if keyword.hasPrefix("-") {
            return getMatchingSystemCommands(keyword)
        }
        return getMatchingTLDRCommands(keyword, table: table)
    }
    
    static func printRealmLocation() {
        if let url = Realm.Configuration.defaultConfiguration.fileURL {
            print("open ", url.absoluteString.replacingOccurrences(of: "file://", with: ""))
        }
    }
    
}
