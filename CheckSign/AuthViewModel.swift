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
    @Published var isAuthenticated = false
    @Published var user: User?
    var context: ModelContext?

    func signIn(phone: String, password: String) {
        guard let context = context else { return }
        let request = FetchDescriptor<User>(predicate: #Predicate { $0.phoneNumber == phone && $0.password == password })
        if let result = try? context.fetch(request).first {
            self.user = result
            self.isAuthenticated = true
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
