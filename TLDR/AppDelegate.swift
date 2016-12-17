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

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        FileManager.copyBundleToDocument(replace: false)
        
        let splitViewController = self.window!.rootViewController as! UISplitViewController
        splitViewController.preferredDisplayMode = .allVisible
        let leftNavController = splitViewController.viewControllers.first as! UINavigationController
        let masterViewController = leftNavController.topViewController as! MasterViewController
        let rightNavController = splitViewController.viewControllers.last as! UINavigationController
        let detailViewController = rightNavController.viewControllers.last as! DetailViewController
        masterViewController.delegate = detailViewController
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
    }

    func applicationWillTerminate(_ application: UIApplication) {
    }


}
