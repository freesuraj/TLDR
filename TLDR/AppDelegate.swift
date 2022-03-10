//
//  AppDelegate.swift
//  TLDR
//
//  Created by Suraj Pathak on 8/1/16.
//  Copyright © 2016 Suraj Pathak. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        FileManager.copyBundleToDocument(replace: false)
        
//        let splitViewController = self.window!.rootViewController as! UISplitViewController
//        let leftNavController = splitViewController.viewControllers.first as! UINavigationController
//        let masterViewController = leftNavController.topViewController as! MasterViewController
//        let rightNavController = splitViewController.viewControllers.last as! UINavigationController
//        let detailViewController = rightNavController.viewControllers.last as! DetailViewController
//        masterViewController.delegate = detailViewController
        return true
    }

}
