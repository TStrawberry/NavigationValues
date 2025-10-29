//
//  LastNameInputScreen.swift
//  Demo
//
//  Created by TangTao on 2025/9/12.
//

import SwiftUI
import NavigationValues

struct LastNameInputScreen: View {
    @Environment(\.navigationValues) var navigationValues
    
    var body: some View {
        @Bindable var navigationValues = navigationValues
        
        VStack {
            TextField("input last name", text: $navigationValues.lastName)
                .textFieldStyle(.roundedBorder)
            NavigationLink("To show full name", value: Screen.fullNameScreen)
        }
        .navigationTitle("LastNameInputScreen")
    }
}

#Preview {
    LastNameInputScreen()
}
