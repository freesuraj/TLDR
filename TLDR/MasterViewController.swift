//
//  MasterViewController.swift
//  TLDR
//
//  Created by Suraj Pathak on 13/12/16.
//  Copyright © 2016 Suraj Pathak. All rights reserved.
//

import UIKit

protocol CommandSelectionDelegate: class {
    func commandSelected(command: Command)
}

class MasterViewController: UITableViewController {
    
    weak var delegate: CommandSelectionDelegate?
    
    enum State {
        case search(String?)
        case favs
        case history
        case top
        
        var commands: [Command] {
            switch self {
            case .search(let keyword):
                return StoreManager.commands(withKeyword: keyword)
            case .favs:
                return []
            default:
                return []
            }
        }
        
    }
    
    var appState: State! {
        didSet {
            list = self.appState.commands
        }
    }
    
    var list: [Command] = [] {
        didSet {
            tableView.reloadData()
        }
    }
    
    var searchBar: UISearchBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Commands"
        searchBar = UISearchBar(frame: CGRect(origin: .zero, size: CGSize(width: view.frame.width, height: 44)))
        tableView.tableHeaderView = searchBar
        searchBar.delegate = self
        appState = .search(nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return list.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: UITableViewCell
        if let existingCell = tableView.dequeueReusableCell(withIdentifier: String(describing: UITableViewCell.self)) {
            cell = existingCell
        } else {
            cell = UITableViewCell(style: .subtitle, reuseIdentifier: String(describing: UITableViewCell.self))
            cell.accessoryType = .disclosureIndicator
        }
        
        cell.textLabel?.text = list[indexPath.row].name
        cell.detailTextLabel?.text = list[indexPath.row].type

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let command = list[indexPath.row]
        self.delegate?.commandSelected(command: command)
        if let detailViewController = self.delegate as? DetailViewController {
        splitViewController?.showDetailViewController(detailViewController, sender: nil)
        }
    }

}

extension MasterViewController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        appState = .search(searchBar.text)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = nil
        appState = .search(nil)
        searchBar.resignFirstResponder()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
}
