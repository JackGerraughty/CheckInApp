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
    
    enum JoinOrgError: Error, LocalizedError {
        case invalidFormat, notFound
        var errorDescription: String? {
            switch self {
            case .invalidFormat: return "That link isn’t formatted correctly."
            case .notFound:      return "No organization matches that link."
            }
        }
    }
    
    
    
    func shareLink(for org: Organization) -> URL? {
        var comps = URLComponents()
        comps.scheme = "checksign"
        comps.host   = "join"
        comps.queryItems = [URLQueryItem(name: "org", value: org.id)]
        return comps.url          // checksign://join?org=123‑456‑789
    }
    
    @MainActor
    func joinOrganization(withLink link: String, user: User) throws {
        guard let context = context,
              let url = URL(string: link),
              let comps = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
            throw JoinOrgError.invalidFormat
        }
        
        // Accept either scheme
        let orgID: String? = {
            if url.scheme == "checksign" {
                return comps.queryItems?.first { $0.name == "org" }?.value
            } else {                               // https://checksign.app/join/<id>
                return url.pathComponents.dropFirst().first // “join” then <id>
                           .flatMap { $0 == "join" ? url.pathComponents.last : nil }
            }
        }()
        guard let id = orgID else { throw JoinOrgError.invalidFormat }
        
        let descriptor = FetchDescriptor<Organization>(predicate: #Predicate { $0.id == id })
        guard let org = try context.fetch(descriptor).first else { throw JoinOrgError.notFound }
        
        if !org.members.contains(user.phoneNumber) {
            org.members.append(user.phoneNumber)
            try context.save()
            fetchOrganizations(for: user)        // refresh list seen in Profile tab
        }
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


    @MainActor
    func syncFromServer(for user: User) async {
        do {
            let remote = try await APIService.shared.fetchOrgs(for: user.id)
            merge(remoteOrgs: remote, currentUser: user)
        } catch {
            print("sync error:", error)
        }
    }

    private func merge(remoteOrgs: [OrgDTO], currentUser user: User) {
        guard let context = context else { return }
        
        for dto in remoteOrgs {
            let idToMatch = dto.id                           // ← plain String
            
            let descriptor = FetchDescriptor<Organization>(
                predicate: #Predicate { org in               // org is Organization
                    org.id == idToMatch                      // ✅ keyPath == value
                }
            )
            
            if let local = try? context.fetch(descriptor).first {
                local.name      = dto.name
                local.latitude  = dto.latitude
                local.longitude = dto.longitude
                local.members   = dto.members
            } else {
                let fresh = Organization(name: dto.name,
                                          members: dto.members,
                                          latitude: dto.latitude,
                                          longitude: dto.longitude)
                fresh.id = idToMatch
                context.insert(fresh)
            }
        }
        
        try? context.save()
        fetchOrganizations(for: user)                        // refresh UI
    }

}
