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
    @Environment(\.modelContext) private var context
    
    func createOrganization(name: String) {
        let org = Organization(name: name)
        context.insert(org)
        try? context.save()
        organizations.append(org)
    }
    
    func joinOrganization(withLink link: String) {
        // Decode link to find org ID and join
    }
}
