//
//  OrganizationViewModel.swift
//  CheckSign
//
//  Created by Jack Gerraughty on 4/15/25.
//

import Foundation
import SwiftUI
import MapKit
import CoreLocation
import SwiftData

class OrganizationViewModel: ObservableObject {
    @Published var organizations: [Organization] = []
    @Published var currentOrg: Organization?
    var context: ModelContext?
    
    func createOrganization(name: String, for user: User) {
        guard let context = context else { return }
        let org = Organization(name: name)
        org.members.append(user.phoneNumber)
        context.insert(org)
        do {
            try context.save()
            organizations.append(org)
            fetchOrganizations(for: user)
        } catch {
            print("❌ Failed to save organization: \(error.localizedDescription)")
        }
    }
    
    func joinOrganization(withLink link: String) {
        // Decode link to find org ID and join
    }
    
    func fetchOrganizations(for user: User) {
        guard let context = context else { return }

        do {
            let allOrgs = try context.fetch(FetchDescriptor<Organization>())
            self.organizations = allOrgs.filter { $0.members.contains(user.phoneNumber) }
        } catch {
            print("❌ Failed to fetch organizations: \(error.localizedDescription)")
        }
    }


}
