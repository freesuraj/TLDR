//
//  DetailViewController.swift
//  TLDR
//
//  Created by Suraj Pathak on 13/12/16.
//  Copyright © 2016 Suraj Pathak. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {

    @IBOutlet var textView: UITextView!
    
    var command: Command? {
        didSet {
            if let value = command {
                textView.attributedText = value.output
                self.title = value.name
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}

extension DetailViewController: CommandSelectionDelegate {
    func commandSelected(command: Command) {
        self.command = command
    }
}
