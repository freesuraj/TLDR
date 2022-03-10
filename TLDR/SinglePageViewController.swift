//
//  SinglePageViewController.swift
//  TLDR
//
//  Created by Suraj Pathak on 10/3/2022.
//  Copyright © 2022 Suraj Pathak. All rights reserved.
//

import UIKit

let cellIdentifier = "cellIdentifier"

class SinglePageViewController: UIViewController {

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
            DispatchQueue.main.async(execute: {
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
                                                                        [NSAttributedString.Key.foregroundColor:UIColor.lightText])
        commandTextField.clearButtonMode = .always
        commandTextField.clearsOnBeginEditing = true
        // Customize text view
        resultTextView.backgroundColor = UIColor.clear
        resultTextView.textColor = UIColor.white
        resultTextView.font = UIFont(name: "Courier", size: 20)
        resultTextView.textContainer.lineFragmentPadding = 5
        resultTextView.textContainerInset = UIEdgeInsets(top: 5, left: 10, bottom: 5, right: 5)
        resultTextView.isSelectable = true
        resultTextView.isEditable = false
        resultTextView.dataDetectorTypes = .link
    }

    override var prefersStatusBarHidden : Bool {
        return true
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        commandTextField.becomeFirstResponder()
        NotificationCenter.default.addObserver(self, selector: #selector(SinglePageViewController.updateSuggestion), name:
                                                UITextField.textDidChangeNotification, object: commandTextField)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: UITextField.textDidChangeNotification, object: commandTextField)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @objc func updateSuggestion() {
        suggestions = StoreManager.getMatchingCommands(commandTextField.text!)
    }

    func printOut(_ text: NSAttributedString) {
        let currentAttrText = NSMutableAttributedString(attributedString: text)
        currentAttrText.append(NSAttributedString(string: "\n\n"))
        currentAttrText.append(resultTextView.attributedText)
        resultTextView.attributedText = currentAttrText
        resultTextView.scrollRectToVisible(CGRect(origin: CGPoint.zero, size: resultTextView.frame.size), animated: true)
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

extension SinglePageViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
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

    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        suggestions.removeAll()
        return true
    }
}

extension SinglePageViewController: UITextViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        commandTextField.resignFirstResponder()
    }
}

extension SinglePageViewController: UITableViewDelegate, UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return suggestions.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: UITableViewCell?
        if let cachedCell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) {
            cell = cachedCell
        } else {
            cell = UITableViewCell(style: .value1, reuseIdentifier: cellIdentifier)
            cell?.backgroundColor = UIColor.clear
            cell?.textLabel?.textColor = UIColor.lightText
        }
        let command = suggestions[(indexPath as NSIndexPath).row]
        cell!.textLabel!.text = command.name
        cell!.detailTextLabel!.text = command.type
        return cell!
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        let command = suggestions[(indexPath as NSIndexPath).row]
        commandTextField.text = command.name
        printOut(command.output)
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
