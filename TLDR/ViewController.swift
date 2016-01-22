//
//  ViewController.swift
//  TLDR
//
//  Created by Suraj Pathak on 8/1/16.
//  Copyright © 2016 Suraj Pathak. All rights reserved.
//

import UIKit

let cellIdentifier = "cellIdentifier"

class ViewController: UIViewController {

    @IBOutlet weak var resultTextView: UITextView!
    @IBOutlet weak var commandTextField: UITextField!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var tableViewHeightConstraint: NSLayoutConstraint!
    var suggestions: [Command] = [] {
        didSet {
            updateTableView()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        Verbose.verboseUpdateBlock = { text in
            dispatch_async(dispatch_get_main_queue(), {
                self.printOut(text)
            })
        }
        NetworkManager.checkAutoUpdate(printVerbose: false)
    }

    func setupView() {
        tableView.dataSource = self
        tableView.delegate = self
        commandTextField.delegate = self
        resultTextView.delegate = self
        tableView.isAccessibilityElement = true
        tableView.accessibilityIdentifier = "tb"
        tableView.accessibilityElementsHidden = false
        tableView.shouldGroupAccessibilityChildren = true
        updateTableView()
        // Customize text field
        commandTextField.attributedPlaceholder = NSAttributedString(string: "_", attributes:
            [NSForegroundColorAttributeName:UIColor.lightTextColor()])
        commandTextField.clearButtonMode = .Always
        commandTextField.clearsOnBeginEditing = true
        // Customize text view
        resultTextView.backgroundColor = UIColor.clearColor()
        resultTextView.textColor = UIColor.whiteColor()
        resultTextView.font = UIFont(name: "Courier", size: 20)
        resultTextView.textContainer.lineFragmentPadding = 5
        resultTextView.textContainerInset = UIEdgeInsets(top: 5, left: 10, bottom: 5, right: 5)
        resultTextView.selectable = true
        resultTextView.editable = false
        resultTextView.dataDetectorTypes = .Link
    }

    override func prefersStatusBarHidden() -> Bool {
        return true
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        commandTextField.becomeFirstResponder()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "updateSuggestion", name:
            UITextFieldTextDidChangeNotification, object: commandTextField)
    }

    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UITextFieldTextDidChangeNotification, object: commandTextField)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func updateSuggestion() {
        suggestions = StoreManager.getMatchingCommands(commandTextField.text!)
    }

    func printOut(text: NSAttributedString) {
        let currentAttrText = NSMutableAttributedString(attributedString: text)
        currentAttrText.appendAttributedString(NSAttributedString(string: "\n\n"))
        currentAttrText.appendAttributedString(resultTextView.attributedText)
        resultTextView.attributedText = currentAttrText
        resultTextView.scrollRectToVisible(CGRect(origin: CGPointZero, size: resultTextView.frame.size), animated: true)
        commandTextField.text = ""
        commandTextField.resignFirstResponder()
        suggestions.removeAll()
    }

    func updateTableView() {
        tableView.reloadData()
        let cellHeight = CGFloat(44.0)
        let maxCells = CGFloat(6.0)
        let cellsCount = min(maxCells, CGFloat(suggestions.count))
        tableViewHeightConstraint.constant = cellsCount * cellHeight
    }
}

extension ViewController: UITextFieldDelegate {
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if !self.suggestions.isEmpty {
            printOut(self.suggestions[0].output)
        } else {
            if let name  = textField.text {
                printOut(TLDRCommand(name: name, type: "common").output)
            }
        }
        suggestions.removeAll()
        return true
    }

    func textFieldShouldClear(textField: UITextField) -> Bool {
        suggestions.removeAll()
        return true
    }
}

extension ViewController: UITextViewDelegate {
    func scrollViewDidScroll(scrollView: UIScrollView) {
        commandTextField.resignFirstResponder()
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
        if let cachedCell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier) {
            cell = cachedCell
        } else {
            cell = UITableViewCell(style: .Value1, reuseIdentifier: cellIdentifier)
            cell?.backgroundColor = UIColor.clearColor()
            cell?.textLabel?.textColor = UIColor.lightTextColor()
        }
        let command = suggestions[indexPath.row]
        cell!.textLabel!.text = command.name
        cell!.detailTextLabel!.text = command.type
        return cell!
    }

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: false)
        let command = suggestions[indexPath.row]
        commandTextField.text = command.name
        printOut(command.output)
    }
}

extension ViewController {

    @IBAction func clearConsole(sender: AnyObject) {
        resultTextView.attributedText = NSMutableAttributedString(string: "")
    }

    @IBAction func showRandomCommand(sender: AnyObject) {
        printOut(SystemCommand.Random.output)
    }

    @IBAction func appendAboutUs(sender: AnyObject) {
        printOut(SystemCommand.Info.output)
    }
}
