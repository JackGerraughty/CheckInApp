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
    var address: String
    

    init(title: String, date: Date, latitude: Double, longitude: Double, attendees: [String] = [], address: String) {
        self.title = title
        self.date = date
        self.latitude = latitude
        self.longitude = longitude
        self.attendees = attendees
        self.address = address
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
    var events: [Event] = [] // ✅ NEW
    
    var latitude: Double
    var longitude: Double

    init(name: String, members: [String] = [], latitude: Double = 0, longitude: Double = 0) {
        self.name = name
        self.members = members
        self.latitude = latitude
        self.longitude = longitude
    }
    
    var coordinate: CLLocationCoordinate2D {
        .init(latitude: latitude, longitude: longitude)
    }
}
