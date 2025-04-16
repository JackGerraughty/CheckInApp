//
//  OrganizationView.swift
//  CheckSign
//
//  Created by Jack Gerraughty on 4/15/25.
//

import Foundation
import SwiftUI

struct OrganizationView: View {
    @ObservedObject var orgVM: OrganizationViewModel

    var body: some View {
        List {
            ForEach(orgVM.organizations) { org in
                Text(org.name)
            }
        }
        .navigationTitle("My Organizations")
        .navigationBarBackButtonHidden(true)
    }
}
