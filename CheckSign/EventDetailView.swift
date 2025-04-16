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
    let event: Event
    @ObservedObject var eventVM: EventViewModel
    @StateObject private var locManager = LocationManager()

    var body: some View {
        VStack {
            Map(coordinateRegion: .constant(MKCoordinateRegion(center: event.location, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))))
                .frame(height: 200)
            Button("Check In") {
                if let location = locManager.lastLocation {
                    eventVM.checkIn(event: event, currentLocation: location)
                }
            }
            if eventVM.checkedIn {
                Text("Checked In Successfully").foregroundColor(.green)
            }
        }.padding()
    }
}
