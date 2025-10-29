//
//  ContentView.swift
//  Demo
//
//  Created by TangTao on 2025/9/12.
//

import SwiftUI
import NavigationValues

struct FirstNameInputScreen: View {
    @Environment(\.navigationValues) var navigationValues
    
    var body: some View {
        @Bindable var navigationValues = navigationValues
        
        VStack {
            TextField("input first name", text: $navigationValues.firstName)
                .textFieldStyle(.roundedBorder)
            NavigationLink("To Input LastName", value: Screen.lastnameInputScreen)
        }
        .navigationTitle("FirstNameInputScreen")
    }
}

#Preview {
    FirstNameInputScreen()
}
