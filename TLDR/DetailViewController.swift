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
                textView?.attributedText = value.output
                self.title = value.name
            }
        }
    }
    
    var favButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        StoreManager.printRealmLocation()
        favButton = UIButton(frame: CGRect(x: 0, y: 0, width: 32, height: 32))
        favButton.setImage(#imageLiteral(resourceName: "fav"), for: .normal)
        favButton.setImage(#imageLiteral(resourceName: "favRed"), for: .selected)
        favButton.setImage(#imageLiteral(resourceName: "favRed"), for: .highlighted)
        favButton.addTarget(self, action: #selector(addFav), for: .touchUpInside)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: favButton)
    }
    
    func forceGoBack() {
        (splitViewController?.viewControllers.first as? UINavigationController)?.popViewController(animated: true)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if var tldrCommand = command as? TLDRCommand {
            favButton.isSelected = tldrCommand.isFavorited
            tldrCommand.isVisited = true
        } else {
            forceGoBack()
        }
    }
    
    @objc func addFav(sender: UIButton) {
        if var tldrCommand = command as? TLDRCommand {
            favButton.isSelected = !tldrCommand.isFavorited
            tldrCommand.isFavorited = favButton.isSelected
        }
    }

}

extension DetailViewController: CommandSelectionDelegate {
    
    func commandSelected(command: Command) {
        self.command = command
    }
    
}
