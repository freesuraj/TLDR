//
//  ViewController.swift
//  TLDR
//
//  Created by Suraj Pathak on 8/1/16.
//  Copyright © 2016 Suraj Pathak. All rights reserved.
//

import UIKit

let CellIdentifier = "CellIdentifier"

class ViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var resultTextView: UITextView!
    @IBOutlet weak var commandTextField: UITextField!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var tableViewHeightConstraint: NSLayoutConstraint!
    
    var suggestions: [String] = [] {
        didSet {
            updateTableView()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateUI()
        
    }
    
    func updateUI() {
        
        tableView.dataSource = self
        tableView.delegate = self
        commandTextField.delegate = self
        updateTableView()
        
        commandTextField.attributedPlaceholder = NSAttributedString(string: "tldr_", attributes: [NSForegroundColorAttributeName:UIColor.lightTextColor()])
        commandTextField.clearButtonMode = .Always
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "updateSuggestion", name: UITextFieldTextDidChangeNotification, object: commandTextField)
        
        resultTextView.backgroundColor = UIColor.blackColor()
        resultTextView.textColor = UIColor.whiteColor()
        resultTextView.font = UIFont(name: "Courier", size: 20)
        resultTextView.contentInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: -10)
        
        resultTextView.selectable = false
        resultTextView.editable = false
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        commandTextField.becomeFirstResponder()
        updateResult()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UITextFieldTextDidChangeNotification, object: commandTextField)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func updateResult() {

        var result = resultTextView.text
        let content = "man\n some command \n lesdjfk \n\n kdjdkfjdk \n"
            
        result = content + result
        resultTextView.text = result
        resultTextView.scrollRectToVisible(CGRect(origin: CGPointZero, size: resultTextView.frame.size), animated: true)
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        suggestions.removeAll()
        return true
    }
    
    func textFieldShouldClear(textField: UITextField) -> Bool {
        suggestions.removeAll()
        return true
    }
    
    func updateSuggestion() {
        print("updating suggestions")
        suggestions = ["man", "cat", "bash", "dall", "galla", "sublime", "atom"]
    }
    
    func updateTableView() {
        tableView.reloadData()
        let cellHeight = CGFloat(32.0)
        let maxCells = CGFloat(4.0)
        let cellsCount = min(maxCells, CGFloat(suggestions.count))
        tableViewHeightConstraint.constant = cellsCount * cellHeight
    }
}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return suggestions.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell: UITableViewCell?
        if let cachedCell = tableView.dequeueReusableCellWithIdentifier(CellIdentifier) {
            cell = cachedCell
        } else {
            cell = UITableViewCell(style: .Value1, reuseIdentifier: CellIdentifier)
            cell?.backgroundColor = UIColor.clearColor()
            cell?.textLabel?.textColor = UIColor.lightTextColor()
        }
        cell!.textLabel!.text = suggestions[indexPath.row]
        cell!.detailTextLabel!.text = "dfd"
        return cell!
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: false)
        commandTextField.text = suggestions[indexPath.row]
        commandTextField.resignFirstResponder()
        suggestions.removeAll()
    }
}

