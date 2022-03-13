//
//  SinglePageViewController.swift
//  TLDR
//
//  Created by Suraj Pathak on 10/3/2022.
//  Copyright © 2022 Suraj Pathak. All rights reserved.
//

import UIKit

class SinglePageViewController: UIViewController {

    @IBOutlet weak var resultTextView: UITextView!
    @IBOutlet weak var commandTextField: UITextField!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var tableViewHeightConstraint: NSLayoutConstraint!
    
    private enum Constants {
        static var cellSize: CGFloat = 44
        static var maxCells = 6
    }
    
    var suggestions: [Command] = [] {
        didSet {
            dataSource?.updateCommands(suggestions)
            updateTableViewSize()
        }
    }
    
    var dataSource: CommandsDataSource?
    var viewModel: SinglePageViewModel?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupViewModel()
        setupVerboseListener()
        NetworkManager.checkAutoUpdate(printVerbose: false)
        showStartupInstruction()
    }

    override var prefersStatusBarHidden : Bool {
        return true
    }
    
    private func showStartupInstruction() {
        printOut(SystemCommand.startupInstruction)
    }
    
    private func setupViewModel() {
        viewModel = SinglePageViewModel(searchField: commandTextField, textView: resultTextView, tableView: tableView)
        dataSource = CommandsDataSource(tableView: self.tableView)
        dataSource?.didSelectCommand = { [weak self] command in
            self?.commandTextField.text = command.name
            self?.printOut(command.output)
        }
        
        viewModel?.didUpdateSearchText = { [unowned self] text in
            suggestions = StoreManager.getMatchingCommands(text)
        }
        
        viewModel?.didEnterSearch = { [unowned self] text in
            if !self.suggestions.isEmpty {
                printOut(self.suggestions[0].output)
            } else {
                if let name  = text {
                    printOut(TLDRCommand.commonType(with: name).output)
                }
            }
            suggestions.removeAll()
        }
        
        viewModel?.didClearSearch = { [unowned self] in
            suggestions.removeAll()
        }
    }
    
    private func setupVerboseListener() {
        Verbose.verboseUpdateBlock = { text in
            DispatchQueue.main.async(execute: {
                self.printOut(text)
            })
        }
    }
    
    private func updateTableViewSize() {
        let cellHeight = CGFloat(Constants.cellSize)
        let maxCells = CGFloat(Constants.maxCells)
        let cellsCount = min(maxCells, CGFloat(suggestions.count))
        tableViewHeightConstraint.constant = cellsCount * cellHeight
    }

    private func printOut(_ text: NSAttributedString) {
        viewModel?.displayConsoleOutput(text)
        suggestions.removeAll()
    }
}

extension SinglePageViewController {

    @IBAction func clearConsole(_ sender: AnyObject) {
        resultTextView.attributedText = NSMutableAttributedString(string: "")
    }

    @IBAction func showRandomCommand(_ sender: AnyObject) {
        printOut(SystemCommand.random.output)
    }

    @IBAction func appendAboutUs(_ sender: AnyObject) {
        printOut(SystemCommand.info.output)
    }
}
