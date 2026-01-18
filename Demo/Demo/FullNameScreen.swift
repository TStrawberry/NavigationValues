//
//  NamesScreen.swift
//  Demo
//
//  Created by TangTao on 2025/9/12.
//

import SwiftUI
import NavigationValues

struct FullNameScreen: View {
    @Environment(\.navigationValues.firstName) var firstName
    @Environment(\.navigationValues.lastName) var lastName
    
    @Environment(\.navigationValues) var navigationValues: NavigationValues
    
    @State var middleName: String = ""
    
    var body: some View {
        VStack {
            Text(firstName + " " + middleName + " " + lastName)
            NavigationLink("To update name", value: Screen.firstnameInputScreen)
            
            TextField("Update middle name for all previous names", text: $middleName)
        }
        .frame(maxHeight: .infinity)
        .onChange(of: middleName) { oldValue, newValue in
            navigationValues.updatePreference(MiddleName.self, value: newValue)
        }
        .onNavigationPreferenceChange(MiddleName.self, perform: { value in
            middleName = value
        })
        .navigationTitle("FullNameScreen")
    }
}

#Preview {
    FullNameScreen()
}
