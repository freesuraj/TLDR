//
//  MasterViewController.swift
//  TLDR
//
//  Created by Suraj Pathak on 13/12/16.
//  Copyright © 2016 Suraj Pathak. All rights reserved.
//

import UIKit

protocol CommandSelectionDelegate: AnyObject {
    func commandSelected(command: Command)
}

class MasterViewController: UITableViewController {
    
    weak var delegate: CommandSelectionDelegate?
    
    var themeColor: UIColor {
        return #colorLiteral(red: 0.7882352941, green: 0.7882352941, blue: 0.8078431373, alpha: 1)
    }
    
    var appState: MasterViewState = .search(nil) {
        didSet {
            dataSource?.updateCommands(appState.commands)
        }
    }
    
    var header: UIView!
    var searchBar: UISearchBar!
    
    var dataSource: MasterViewDataSource?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupHeader()
        self.title = "Commands"
        appState = .search(nil)
        tableView.keyboardDismissMode = .onDrag
        dataSource = MasterViewDataSource(tableView: self.tableView)
        dataSource?.updateCommands(appState.commands)
        dataSource?.didSelectCommand = { [weak self] command in
            self?.delegate?.commandSelected(command: command)
            if let detailViewController = self?.delegate as? DetailViewController {
                self?.splitViewController?.showDetailViewController(UINavigationController(rootViewController: detailViewController), sender: nil)
            }
        }
    }
    
    func setupHeader() {
        searchBar = UISearchBar(frame: CGRect(origin: .zero, size: CGSize(width: view.frame.width, height: 44)))
        searchBar.delegate = self
        searchBar.placeholder = "Type a command to look up, eg. curl"
        let segControl = UISegmentedControl(items: ["All", "Fav", "Recent"])
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
        separator.autoresizingMask = [.flexibleWidth]
        header.addSubview(searchBar)
        header.addSubview(segControl)
        header.addSubview(separator)
        tableView.tableHeaderView = header
    }
    
    @objc func segValueChanged(sender: UISegmentedControl) {
        self.appState = selectedViewState(at: sender.selectedSegmentIndex)
    }
    
    private func selectedViewState(at index: Int) -> MasterViewState {
        switch index {
        case 1: return .favs(searchBar.text)
        case 2: return .history(searchBar.text)
        default: return .search(searchBar.text)
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

