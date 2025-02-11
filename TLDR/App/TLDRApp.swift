//
//  TLDRApp.swift
//  TLDR
//
//  Created by Suraj Pathak on 11/2/2025.
//  Copyright © 2025 Suraj Pathak. All rights reserved.
//

import SwiftUI

@main
struct TLDRApp: App {
    @UIApplicationDelegateAdaptor private var appDelegate: AppDelegate
    
    var body: some Scene {
        WindowGroup {
            ConsoleView()
        }
    }
}
