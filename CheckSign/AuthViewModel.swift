//
//  AuthViewModel.swift
//  CheckSign
//
//  Created by Jack Gerraughty on 4/15/25.
//

import Foundation
import SwiftUI
import MapKit
import CoreLocation
import SwiftData

class AuthViewModel: ObservableObject {
    @Published var loginError: String? = nil
    @Published var isAuthenticated = false
    @Published var user: User?
    @Published var pendingLink: URL?
    var context: ModelContext?
    
    func signIn(phone: String, password: String) {
        guard let context = context else { return }

        let userRequest = FetchDescriptor<User>(predicate: #Predicate { $0.phoneNumber == phone })
        if let user = try? context.fetch(userRequest).first {
            if user.password == password {
                self.user = user
                self.isAuthenticated = true
                self.loginError = nil
            } else {
                self.loginError = "The password for this phone number is incorrect."
            }
        } else {
            self.loginError = "This phone number is not registered. Please sign up instead."
        }
    }

    @MainActor func consumePendingLink(using orgVM: OrganizationViewModel) {
            if let link = pendingLink, let current = user {
                try? orgVM.joinOrganization(withLink: link.absoluteString, user: current)
                pendingLink = nil
            }
        }
    
    func signUp(phone: String, password: String) {
        guard let context = context else { return }
        let newUser = User(phoneNumber: phone, password: password)
        context.insert(newUser)
        try? context.save()
        self.user = newUser
        self.isAuthenticated = true
    }
}
