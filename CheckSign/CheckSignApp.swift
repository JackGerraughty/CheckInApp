//
//  CheckSignApp.swift
//  CheckSign
//
//  Created by Jack Gerraughty on 4/15/25.
//

import SwiftUI
import SwiftData

@main
struct CheckInApp: App {
    var body: some Scene {
        WindowGroup {
            NavigationView {
                LoginView()
            }
            .modelContainer(for: [User.self, Organization.self, Event.self])
        }
    }
}
