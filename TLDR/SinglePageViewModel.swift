//
//  SinglePageViewModel.swift
//  TLDR
//
//  Created by Suraj Pathak on 14/3/2022.
//  Copyright © 2022 Suraj Pathak. All rights reserved.
//

import Foundation
import UIKit

class SinglePageViewModel: NSObject {
    
    private enum Constants {
        static var textViewFont = UIFont(name: "Courier", size: 20)
        static var textViewInset = UIEdgeInsets(top: 5, left: 10, bottom: 5, right: 5)
    }
    
    var searchField: UITextField
    var textView: UITextView
    var tableView: UITableView
    
    var didEnterSearch: ((String?) -> Void)?
    var didClearSearch: (() -> Void)?
    var didUpdateSearchText: ((String) -> Void)?
    
    init(searchField: UITextField, textView: UITextView, tableView: UITableView) {
        self.searchField = searchField
        self.textView = textView
        self.tableView = tableView
        super.init()
        customizeTextView()
        customizeTextField()
    }
    
    func customizeTextField() {
        searchField.attributedPlaceholder = NSAttributedString(string: "_", attributes:
                                                                        [NSAttributedString.Key.foregroundColor:UIColor.lightText])
        searchField.placeholder = ""
        searchField.clearButtonMode = .always
        searchField.clearsOnBeginEditing = true
        searchField.delegate = self
        observeTextFieldUpdate()
    }
    
    private func observeTextFieldUpdate() {
        searchField.becomeFirstResponder()
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(updateSuggestion),
                                               name: UITextField.textDidChangeNotification, object: searchField)
    }
    
    
    @objc func updateSuggestion() {
        didUpdateSearchText?(searchField.text ?? "")
    }
    
    func customizeTextView() {
        textView.delegate = self
        textView.backgroundColor = UIColor.clear
        textView.textColor = UIColor.white
        textView.font = Constants.textViewFont
        textView.textContainer.lineFragmentPadding = 5
        textView.textContainerInset = Constants.textViewInset
        textView.isSelectable = true
        textView.isEditable = false
        textView.dataDetectorTypes = .link
    }
    
    func displayConsoleOutput(_ text: NSAttributedString) {
        let currentAttrText = NSMutableAttributedString(attributedString: text)
        currentAttrText.append(NSAttributedString(string: "\n\n"))
        currentAttrText.append(textView.attributedText)
        textView.attributedText = currentAttrText
        textView.scrollRectToVisible(CGRect(origin: CGPoint.zero, size: textView.frame.size), animated: true)
        searchField.text = ""
        searchField.resignFirstResponder()
    }
    
}

extension SinglePageViewModel: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        didEnterSearch?(textField.text)
        return true
    }

    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        didClearSearch?()
        return true
    }
}

extension SinglePageViewModel: UITextViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        searchField.resignFirstResponder()
    }
}
