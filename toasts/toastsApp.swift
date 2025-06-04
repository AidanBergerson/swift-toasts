//
//  toast_masteryApp.swift
//  toast-mastery
//
//  Created by Aidan Bergerson on 6/4/25.
//

import SwiftUI

@main
struct toastApp: App {
    @StateObject private var toastManager = ToastManager()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(toastManager)
        }
    }
}
