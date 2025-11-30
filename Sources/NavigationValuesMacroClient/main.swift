import NavigationValuesMacro
import SwiftUI

extension EnvironmentValues {
    @Entry var testValue = "asdfasdfasdf"
}

extension String {
    @ValueEntry(\.testValue)
    var testValue: String
}



let value = "sdfasf"

print(value.testValue)

