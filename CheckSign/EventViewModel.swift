//
//  EventViewModel.swift
//  CheckSign
//
//  Created by Jack Gerraughty on 4/15/25.
//

import Foundation
import SwiftUI
import MapKit
import CoreLocation
import SwiftData


class EventViewModel: ObservableObject {
    @Published var events: [Event] = []
    @Published var checkedIn = false
    private let locationManager = CLLocationManager()
    @Environment(\.modelContext) private var context

    func createEvent(title: String, location: CLLocationCoordinate2D) {
        let newEvent = Event(title: title, date: Date(), latitude: location.latitude, longitude: location.longitude)
        context.insert(newEvent)
        try? context.save()
        events.append(newEvent)
    }

    func checkIn(event: Event, currentLocation: CLLocation) {
        let eventLoc = CLLocation(latitude: event.latitude, longitude: event.longitude)
        let distance = currentLocation.distance(from: eventLoc)
        if distance <= 1609.34 {
            checkedIn = true
        }
    }
}
