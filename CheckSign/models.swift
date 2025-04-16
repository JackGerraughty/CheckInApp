//
//  models.swift
//  CheckSign
//
//  Created by Jack Gerraughty on 4/15/25.
//

import Foundation
import SwiftUI
import MapKit
import CoreLocation
import SwiftData

@Model
class Event: Identifiable {
    @Attribute(.unique) var id: String = UUID().uuidString
    var title: String
    var date: Date
    var latitude: Double
    var longitude: Double
    var attendees: [String]

    init(title: String, date: Date, latitude: Double, longitude: Double, attendees: [String] = []) {
        self.title = title
        self.date = date
        self.latitude = latitude
        self.longitude = longitude
        self.attendees = attendees
    }

    var location: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}

@Model
class User: Identifiable {
    @Attribute(.unique) var id: String = UUID().uuidString
    var phoneNumber: String
    var password: String
    var organizations: [String]

    init(phoneNumber: String, password: String, organizations: [String] = []) {
        self.phoneNumber = phoneNumber
        self.password = password
        self.organizations = organizations
    }
}

@Model
class Organization: Identifiable {
    @Attribute(.unique) var id: String = UUID().uuidString
    var name: String
    var members: [String] // User IDs

    init(name: String, members: [String] = []) {
        self.name = name
        self.members = members
    }
}
