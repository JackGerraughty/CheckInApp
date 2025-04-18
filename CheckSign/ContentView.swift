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
                .fullScreenCover(isPresented: $authVM.isAuthenticated) {
                            if let user = authVM.user {
                                MainTabView(user: user)
                                    .navigationBarBackButtonHidden(true)
                            }
                        }
            }
            .padding()
        }
    }
}

struct MainTabView: View {
    let user: User
    init(user: User) {
        self.user = user
        // Makes tab bar background white
        let tabBarAppearance = UITabBarAppearance()
        tabBarAppearance.configureWithOpaqueBackground()
        tabBarAppearance.backgroundColor = .white
        UITabBar.appearance().standardAppearance = tabBarAppearance
        UITabBar.appearance().scrollEdgeAppearance = tabBarAppearance
    }
    @Environment(\.modelContext) var context
    @StateObject private var orgVM = OrganizationViewModel()
    var body: some View {
        TabView {
            CheckInTabView()
                .tabItem {
                    Label("Check In", systemImage: "checkmark.circle.fill")
                }

            CreateOrganizationView(orgVM: orgVM, user: user)
                .tabItem {
                    Label("Create Event", systemImage: "calendar.badge.plus")
                }

            ProfileView(user: user)
                .tabItem {
                    Label("Profile", systemImage: "person.fill")
                }
        }
        .onAppear {
            orgVM.context = context
            orgVM.fetchOrganizations(for: user)
        }
    }
}


struct ProfileView: View {
    @StateObject private var orgVM = OrganizationViewModel()
    @Environment(\.modelContext) private var context

    var user: User

    var body: some View {
        ZStack(alignment: .top) {
            Color(red: 250/255, green: 243/255, blue: 255/255)
                .ignoresSafeArea()

            VStack(spacing: 20) {
                // Header
                HStack {
                    Spacer().frame(width: 50)
                    Text("Jack Gerraughty ⌄")
                        .font(.title2)
                        .fontWeight(.bold)
                        .frame(maxWidth: .infinity, alignment: .center)
                    HStack(spacing: 10) {
                        Image(systemName: "link")
                        Image(systemName: "line.3.horizontal")
                    }
                    .frame(width: 50, alignment: .trailing)
                }
                .padding(.horizontal)

                // Profile Info
                VStack(spacing: 10) {
                    Image("profile")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 100, height: 100)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(Color.white, lineWidth: 3))

                    Text("@JackGerraughty")
                        .font(.title3)
                        .bold()

                    HStack(spacing: 16) {
                        VStack {
                            Text("6").font(.title2).bold()
                            Text("Following").font(.caption)
                        }
                        VStack {
                            Text("243").font(.title2).bold()
                            Text("Followers").font(.caption)
                        }
                        VStack {
                            Text("14.7K").font(.title2).bold()
                            Text("Likes").font(.caption)
                        }
                    }

                    Button("Edit Profile") {}
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(Color.gray)
                        .foregroundColor(.white)
                        .cornerRadius(8)

                    Text("San Diego -> Arizona\ninstagram: JackGerraughty")
                        .font(.footnote)
                        .multilineTextAlignment(.center)
                }

                Divider()

                // Organization Section
                if orgVM.organizations.isEmpty {
                    Spacer()
                    VStack(spacing: 16) {
                        Text("No organizations")
                            .font(.headline)

                        NavigationLink(destination: CreateOrganizationView(orgVM: orgVM, user: user)) {
                            Text("Create Organization")
                                .padding()
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                        .padding(.horizontal)
                    }
                    .padding()
                    Spacer()
                .onAppear {
                    orgVM.context = context
                    orgVM.fetchOrganizations(for: user)
                }
                } else {
                    ScrollView {
                        VStack(spacing: 12) {
                            ForEach(orgVM.organizations) { org in
                                Button(action: {
                                    orgVM.currentOrg = org
                                }) {
                                    HStack {
                                        VStack(alignment: .leading) {
                                            Text(org.name)
                                                .font(.headline)
                                            Text("Members: \(org.members.count)")
                                                .font(.subheadline)
                                                .foregroundColor(.gray)
                                        }
                                        Spacer()
                                        Image(systemName: "chevron.right")
                                            .foregroundColor(.gray)
                                    }
                                    .padding()
                                    .background(Color.white)
                                    .cornerRadius(10)
                                    .shadow(color: .gray.opacity(0.2), radius: 5, x: 0, y: 2)
                                }
                            }
                        }
                        .padding()
                    }
                }

                Spacer()
            }
            .padding()
        }
    }
}


struct CreateOrganizationView: View {
    @ObservedObject var orgVM: OrganizationViewModel
    @Environment(\.dismiss) var dismiss
    @State private var orgName = ""
    @State private var selectedImage: UIImage? = nil
    @State private var isPickerPresented = false
    var user: User
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Create Organization")
                .font(.title)
                .padding(.top)
            
            TextField("Organization Name", text: $orgName)
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(10)
                .padding(.horizontal)
            
            Button(action: {
                isPickerPresented = true
            }) {
                if let image = selectedImage {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .frame(height: 150)
                        .cornerRadius(10)
                        .padding(.horizontal)
                } else {
                    Text("Upload Picture")
                        .foregroundColor(.blue)
                        .padding()
                        .background(Color.white)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.blue, lineWidth: 1)
                        )
                        .padding(.horizontal)
                }
            }
            .sheet(isPresented: $isPickerPresented) {
                ImagePicker(image: $selectedImage)
            }
            
            Spacer()
            
            Button("Save") {
                orgVM.createOrganization(name: orgName, for: user)
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    dismiss()
                }
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(10)
            .padding(.horizontal)
        }
    }
}

struct ImagePicker: UIViewControllerRepresentable {
    @Binding var image: UIImage?

    func makeCoordinator() -> Coordinator {
        return Coordinator(self)
    }

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        let parent: ImagePicker

        init(_ parent: ImagePicker) {
            self.parent = parent
        }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[.originalImage] as? UIImage {
                parent.image = image
            }
            picker.dismiss(animated: true)
        }
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
