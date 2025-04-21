//
//  EventListView.swift
//  CheckSign
//
//  Created by Jack Gerraughty on 4/15/25.
//

import Foundation
import SwiftUI
import MapKit
import CoreLocation
import SwiftData

struct EventListView: View {
    @ObservedObject var eventVM: EventViewModel

    var body: some View {
        List(eventVM.events) { event in
            NavigationLink(destination: EventDetailView(event: event)) {
                VStack(alignment: .leading) {
                    Text(event.title)
                        .font(.headline)
                    Text(event.date, style: .date)
                }
            }
        }.navigationTitle("Events")
    }
}
