//
//  MasterViewDataSource.swift
//  TLDR
//
//  Created by Suraj Pathak on 10/3/2022.
//  Copyright © 2022 Suraj Pathak. All rights reserved.
//

import Foundation
import UIKit

class MasterViewDataSource: NSObject {
    
    var didSelectCommand: ((Command) -> Void)?
    
    private var commands: [Command] = [] {
        didSet {
            tableView.reloadData()
        }
    }
    
    private let tableView: UITableView
    
    required init(tableView: UITableView) {
        self.tableView = tableView
        super.init()
        self.tableView.dataSource = self
        self.tableView.delegate = self
    }
    
    func updateCommands(_ commands: [Command]) {
        self.commands = commands
    }
}

extension MasterViewDataSource: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        commands.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: UITableViewCell
        if let existingCell = tableView.dequeueReusableCell(withIdentifier: String(describing: UITableViewCell.self)) {
            cell = existingCell
        } else {
            cell = UITableViewCell(style: .subtitle, reuseIdentifier: String(describing: UITableViewCell.self))
            cell.accessoryType = .disclosureIndicator
        }
        
        cell.textLabel?.text = commands[indexPath.row].name
        cell.detailTextLabel?.text = commands[indexPath.row].type

        return cell
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let command = commands[indexPath.row]
        didSelectCommand?(command)
    }
}
