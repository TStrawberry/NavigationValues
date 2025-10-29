//
//  NamesScreen.swift
//  Demo
//
//  Created by TangTao on 2025/9/12.
//

import SwiftUI
import NavigationValues

struct FullNameScreen: View {
    @Environment(\.navigationValues.firstName) var firstname
    @Environment(\.navigationValues.lastName) var lastname
    
    @Environment(\.navigationValues) var navigationValues: NavigationValues
    
    @State var middleName: String = ""
    
    var body: some View {
        VStack {
            Text(firstname + " " + middleName + " " + lastname)
            NavigationLink("To update name", value: Screen.firstnameInputScreen)
            
            TextField("Update middle name for all previous names", text: $middleName)
        }
        .frame(maxHeight: .infinity)
        .onChange(of: middleName) { oldValue, newValue in
            navigationValues.updatePreferences(MiddleName.self, value: newValue)
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
