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
    @StateObject private var authVM = AuthViewModel()
    @StateObject private var orgVM = OrganizationViewModel()
    
    var body: some Scene {
        WindowGroup {
            NavigationView {
                LoginView()
                    .environmentObject(authVM)
                    .environmentObject(orgVM)
                    .onOpenURL { url in
                        if let currentUser = authVM.user {
                            do {
                                try orgVM.joinOrganization(withLink: url.absoluteString, user: currentUser)
                            } catch {
                                print("❌ deep‑link join failed:", error.localizedDescription)
                            }
                        } else {
                            authVM.pendingLink = url
                        }
                    }
                    .onChange(of: authVM.user, initial: false) { _, _ in
                        authVM.consumePendingLink(using: orgVM)
                    }
            }
            .modelContainer(for: [User.self, Organization.self, Event.self])
        }
    }
}
