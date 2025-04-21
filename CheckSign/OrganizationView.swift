
//
//  OrganizationView.swift
//  CheckSign
//
//  Created by Jack Gerraughty on 4/15/25.
//

import Foundation
import SwiftUI

struct OrganizationView: View {
    @Environment(\.modelContext) private var context
    @State private var newEventTitle = ""
    @State private var newEventAddress = ""
    @State var organization: Organization
    @StateObject private var eventVM = EventViewModel()


    var body: some View {
        VStack {
            Text("Events for \(organization.name)")
                .font(.title2)
                .padding(.top)

            List {
                ForEach(organization.events) { event in
                    NavigationLink(destination: EventDetailView(event: event)) {
                        Text(event.title)
                    }
                }

                Section(header: Text("Create New Event")) {
                    TextField("Event Title", text: $newEventTitle)
                    TextField("Event Address", text: $newEventAddress)
                    Button("Add Event") {
                        let newEvent = Event(
                            title: newEventTitle,
                            date: .now,
                            latitude: 0,  // Placeholder, replace with real location
                            longitude: 0,
                            address: newEventAddress
                        )
                        organization.events.append(newEvent)
                        context.insert(newEvent)
                        newEventTitle = ""
                        newEventAddress = ""
                    }
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .padding()
    }
}

