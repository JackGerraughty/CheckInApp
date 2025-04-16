//
//  ContentView.swift
//  CheckSign
//
//  Created by Jack Gerraughty on 4/15/25.
//

import SwiftUI
import MapKit
import CoreLocation
import SwiftData
import SwiftUI

// MARK: - Views
struct LoginView: View {
    @State private var phone = ""
    @State private var password = ""
    @StateObject var authVM = AuthViewModel()
    @Environment(\.modelContext) var context

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                Label("Welcome To CheckIn", systemImage: "person.crop.circle.fill")
                    .font(.title2)
                    .padding(.bottom, 10)
                VStack {
                    TextField("Phone Number", text: $phone)
                        .textContentType(.telephoneNumber)
                        .keyboardType(.numberPad)
                        .padding()
                        .background(Color.gray.opacity(0.15))
                        .cornerRadius(8)
                    
                    SecureField("Password", text: $password)
                        .padding()
                        .background(Color.gray.opacity(0.15))
                        .cornerRadius(8)
                    
                    Button("Login") {
                        authVM.context = context
                        authVM.signIn(phone: phone, password: password)
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(phone.isEmpty || password.isEmpty)
                    .padding()
                    
                    Button("Sign Up") {
                        authVM.context = context
                        authVM.signUp(phone: phone, password: password)
                    }
                    .buttonStyle(.bordered)
                    .disabled(phone.isEmpty || password.isEmpty)
                    .padding()
                }
                .padding()
                NavigationLink(destination: MainTabView().navigationBarBackButtonHidden(true), isActive: $authVM.isAuthenticated) {
                    EmptyView()
                }
            }
            .padding()
        }
    }
}

struct MainTabView: View {
    var body: some View {
        TabView {
            CheckInTabView()
                .tabItem {
                    Label("Check In", systemImage: "checkmark.circle.fill")
                }
            CreateEventView()
                .tabItem {
                    Label("Create Event", systemImage: "calendar.badge.plus")
                }
            ProfileView()
                .tabItem {
                    Label("Profile", systemImage: "person.fill")
                }
        }
    }
}

struct ProfileView: View {
    var body: some View {
        Text("Profile Screen")
            .font(.title)
            .padding()
    }
}

struct CreateEventView: View {
    var body: some View {
        Text("Create Event Screen")
            .font(.title)
            .padding()
    }
}

struct CheckInTabView: View {
    var body: some View {
        Text("Check In Screen")
            .font(.title)
            .padding()
    }
}



// MARK: - Location Manager
class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let manager = CLLocationManager()
    @Published var lastLocation: CLLocation?

    override init() {
        super.init()
        manager.delegate = self
        manager.requestWhenInUseAuthorization()
        manager.startUpdatingLocation()
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        lastLocation = locations.first
    }
}
