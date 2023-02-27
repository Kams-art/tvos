//
//  tvApp.swift
//  tv
//
//  Created by Antoine Gonthier on 10/02/2023.
//  Copyright © 2023 The Chromium Authors. All rights reserved.
//

import SwiftUI
import Firebase

@main
struct tvApp: App {
    init () {
        FirebaseApp.configure()
    }
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
