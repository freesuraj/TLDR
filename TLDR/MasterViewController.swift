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
    
    var themeColor: UIColor {
        return #colorLiteral(red: 0.7882352941, green: 0.7882352941, blue: 0.8078431373, alpha: 1)
    }
    
    enum State {
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
                return []
            }
        }
        
        func updated(withText text: String?) -> State {
            switch self {
            case .search(_): return .search(text)
            case .favs(_): return .favs(text)
            case .history(_): return .history(text)
            default:
                return self
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
    
    var header: UIView!
    var searchBar: UISearchBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupHeader()
        self.title = "Commands"
        appState = .search(nil)
        tableView.keyboardDismissMode = .onDrag
    }
    
    func setupHeader() {
        searchBar = UISearchBar(frame: CGRect(origin: .zero, size: CGSize(width: view.frame.width, height: 44)))
        searchBar.delegate = self
        let segControl = UISegmentedControl(items: [#imageLiteral(resourceName: "list"), #imageLiteral(resourceName: "fav"), #imageLiteral(resourceName: "history")])
        segControl.frame = CGRect(x: 0, y: searchBar.frame.height, width: view.frame.width, height: 44)
        searchBar.tintColor = themeColor
        segControl.tintColor = themeColor
        segControl.addTarget(self, action: #selector(segValueChanged), for: .valueChanged)
        segControl.selectedSegmentIndex = 0
        searchBar.autoresizingMask = [.flexibleWidth]
        segControl.autoresizingMask = [.flexibleWidth]
        segControl.removeBorders(withThemeColor: themeColor)
        let separator = UIView(frame: CGRect(x: 0, y: segControl.frame.maxY, width: view.frame.width, height: 1))
        header = UIView(frame: CGRect(origin: .zero, size: CGSize(width: view.frame.width, height: searchBar.frame.height + segControl.frame.height+1)))
        separator.backgroundColor = themeColor
        header.addSubview(searchBar)
        header.addSubview(segControl)
        header.addSubview(separator)
        tableView.tableHeaderView = header
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func segValueChanged(sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 { self.appState = State.search(searchBar.text) }
        if sender.selectedSegmentIndex == 1 { self.appState = State.favs(searchBar.text) }
        if sender.selectedSegmentIndex == 2 { self.appState = State.history(searchBar.text) }
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
        appState = appState.updated(withText: searchText)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = nil
        appState = appState.updated(withText: nil)
        searchBar.resignFirstResponder()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
}

extension UISegmentedControl {
    
    func removeBorders(withThemeColor themeColor: UIColor) {
        self.tintColor = themeColor
        setBackgroundImage(imageWithColor(color: UIColor.white), for: .normal, barMetrics: .default)
        setBackgroundImage(imageWithColor(color: themeColor), for: .selected, barMetrics: .default)
        setDividerImage(imageWithColor(color: UIColor.clear), forLeftSegmentState: .normal, rightSegmentState: .normal, barMetrics: .default)
    }
    
    // create a 1x1 image with this color
    private func imageWithColor(color: UIColor) -> UIImage? {
        let rect = CGRect(x: 0.0, y: 0.0, width: 1.0, height: 1.0)
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()
        context?.setFillColor(color.cgColor)
        context?.fill(rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
    
}
