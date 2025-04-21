//
//  EventDetailView.swift
//  CheckSign
//
//  Created by Jack Gerraughty on 4/15/25.
//

import Foundation
import SwiftUI
import MapKit
import CoreLocation
import SwiftData



struct EventDetailView: View {
    @Environment(\.modelContext) private var context
    @ObservedObject var locationManager = LocationManager()
    @State private var checkInMessage = ""
    @State private var hasCheckedIn = false

    let event: Event

    var body: some View {
        VStack(spacing: 20) {
            Text(event.title)
                .font(.largeTitle)
                .padding(.top)

            Text("Date: \(event.date.formatted())")
            
            if !event.address.isEmpty {
                Text("Location: \(event.address)")
                    .font(.subheadline)
            }

            if event.latitude != 0 && event.longitude != 0 {
                Map(coordinateRegion: .constant(
                    MKCoordinateRegion(
                        center: CLLocationCoordinate2D(latitude: event.latitude, longitude: event.longitude),
                        span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
                    )
                ), annotationItems: [event]) { event in
                    MapMarker(coordinate: event.location)
                }
                .frame(height: 200)
            }

            if !checkInMessage.isEmpty {
                Text(checkInMessage)
                    .foregroundColor(.red)
            }

            Button("RSVP / Check In") {
                if hasCheckedIn { return }
                if event.latitude == 0 && event.longitude == 0 {
                    checkInMessage = "You checked in"
                    hasCheckedIn = true
                } else if let userLoc = locationManager.lastLocation {
                    let eventLocation = CLLocation(latitude: event.latitude, longitude: event.longitude)
                    let distance = userLoc.distance(from: eventLocation)
                    if distance <= 1609.34 {
                        checkInMessage = "You checked in"
                        if let phone = try? context.fetch(FetchDescriptor<User>()).first?.phoneNumber {
                            if !event.attendees.contains(phone) {
                                event.attendees.append(phone)
                                try? context.save()
                            }
                        }
                        hasCheckedIn = true
                    } else {
                        checkInMessage = "You are not at the desired location"
                    }
                } else {
                    checkInMessage = "Location not found. Please ensure location permissions are enabled."
                }
            }
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(10)

            Spacer()
        }
        .padding()
    }
}


