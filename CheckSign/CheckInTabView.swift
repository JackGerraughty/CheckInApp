//
//  CheckInTabView.swift
//  CheckSign
//
//  Created by Jack Gerraughty on 4/20/25.
//

import Foundation
import SwiftUI
import MapKit
import CoreLocation
import SwiftData

struct CheckInTabView: View {
    @Environment(\.modelContext) private var context
    @ObservedObject private var locationManager = LocationManager()
    @State private var allEvents: [Event] = []

    @State private var mapRegion = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194),
        span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
    )

    var body: some View {
        NavigationStack {
            VStack {
                Map(coordinateRegion: $mapRegion, annotationItems: allEvents) { event in
                    MapAnnotation(coordinate: event.location) {
                        NavigationLink(destination: EventDetailView(event: event)) {
                            Image(systemName: "mappin.circle.fill")
                                .foregroundColor(.red)
                                .font(.title)
                        }
                    }
                }
                .frame(height: 300)

                List(allEvents) { event in
                    NavigationLink(destination: EventDetailView(event: event)) {
                        VStack(alignment: .leading) {
                            Text(event.title)
                                .font(.headline)
                            Text(event.date.formatted())
                        }
                    }
                }
            }
            .navigationTitle("Check In")
            .onAppear {
                if let userLoc = locationManager.lastLocation?.coordinate {
                    mapRegion.center = userLoc
                }

                do {
                    let events = try context.fetch(FetchDescriptor<Event>())
                    allEvents = events
                } catch {
                    print("❌ Error fetching events: \(error.localizedDescription)")
                }
            }
        }
    }
}

