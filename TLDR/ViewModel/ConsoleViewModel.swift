//
//  ConsoleViewModel.swift
//  TLDR
//
//  Created by Suraj Pathak on 11/2/2025.
//  Copyright © 2025 Suraj Pathak. All rights reserved.
//

import SwiftUI

@MainActor
@Observable class ConsoleViewModel {
    var text: NSMutableAttributedString = NSMutableAttributedString(string: "")
    
    init() {
        listenForUpdates()
    }
    
    private func update(_ output: NSAttributedString) {
        let currentAttrText = NSMutableAttributedString(attributedString: text)
        currentAttrText.append(NSAttributedString(string: "\n\n"))
        currentAttrText.append(output)
        text = currentAttrText
    }
    
    func clearConsole() {
        text = NSMutableAttributedString(string: "")
    }
    
    private func listenForUpdates() {
        Verbose.verboseUpdateBlock = { [weak self] text in
            DispatchQueue.main.async(execute: {
                self?.update(text)
            })
        }
    }
}
